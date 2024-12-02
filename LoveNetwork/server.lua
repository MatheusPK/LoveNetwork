local path = string.match(..., "(.*%.).*$")
local class = require(path .. 'class')
local package = require(path .. 'package')
local utils = require(path .. 'utils')
local bitfield = require(path .. 'bitfield')
local coder = require(path .. 'coder')
local socket = require('socket')

local Server = class('Server')

function Server:init(host, port, tickRate)
    self.socket = socket:udp()
    self.socket:setsockname(host, port)
    self.socket:settimeout(0)

    self.clients = {}
    self.event_triggers = {}
    self.acks = {}
    self.tick_rate = 1 / tickRate
    self.tick_count = 0
    self.sequence = 0
    self.biggestPackage = 0
end

function Server:update(dt)
    local data, ip, port = self.socket:receivefrom()

    if data then
        local pkg = assert(package:decode(data))
        pkg.ip = ip
        pkg.port = port
        if pkg:isValid() then
            pkg.content = coder:decode(pkg.content, pkg.header.event)
            self:processPackage(pkg)
        end
    end

    self.tick_count = self.tick_count + dt
    if self.tick_count >= self.tick_rate then
        self:sendWorldSnapshot()
        self.tick_count = self.tick_count - self.tick_rate
    end
end

function Server:sendWorldSnapshot()
    local worldStates = self:renderWorldState()
    self.sequence = self.sequence + 1

    for i = 1, #self.clients do
        local client = self.clients[i]
        local worldStatePkg = package('SERVER', self.sequence, 0, 0, NETWORK_EVENTS.WORLD_STATE, worldStates[client.id])
        worldStatePkg.content = coder:encode(worldStatePkg.content, worldStatePkg.header.event)
        local encoded_package = worldStatePkg:encode(socket.gettime())
        self.biggestPackage = math.max(string.len(encoded_package), self.biggestPackage)
        self:sendTo(client, encoded_package)
    end
end

function Server:processPackage(pkg)
    local event = pkg.header.event

    if event == NETWORK_EVENTS.CONNECT then
        self:newClient(pkg.header.id, pkg.ip, pkg.port)
    end

    if event == NETWORK_EVENTS.DISCONNECT then
        self:removeClient(pkg.header.id)
    end

    self:registerPing(pkg)
    self:registerAck(pkg)
    self:callEventTrigger(pkg)
end

-- Create world state and broadcast
function Server:renderWorldState() end

function Server:newClient(id, ip, port)
    local newClient = {
        id = id,
        ip = ip,
        port = port,
        ack = 0,
        ack_bitfield = bitfield(),
        world_snapshots = {},
        average_arrive_ping = 0,
        total_arrive_ping = 0,
        pkg_count = 0
    }
    table.insert(self.clients, newClient)
    self.clients[id] = #self.clients
end

function Server:removeClient(id)
    local lastClientIndex = #self.clients
    utils:swap(self.clients, self.clients[id], lastClientIndex)
    table.remove(self.clients, lastClientIndex)
end

function Server:callEventTrigger(pkg)
    local clientIndex = self.clients[pkg.header.id]
    local client = self.clients[clientIndex]
    local trigger = self.event_triggers[pkg.header.event]
    if client and trigger then
        trigger(pkg, client)
    end
end

function Server:sendTo(client, data)
    self.socket:sendto(data, client.ip, client.port)
end

function Server:onReceive(event, trigger)
    self.event_triggers[event] = trigger
end

function Server:registerScheme(event, scheme)
    coder.schemes[event] = scheme
end

-- Save client last package received
function Server:registerAck(pkg)
    local clientId = pkg.header.id
    local client = self:getClientById(clientId)

    if not client then return end

    if client.ack < pkg.header.sequence then
        local sequenceDifference = pkg.header.sequence - client.ack
        client.ack = pkg.header.sequence
        client.ack_bitfield:shiftLeft(sequenceDifference)
        client.ack_bitfield:turnOn(1)
    end
end

function Server:registerPing(pkg)
    local clientId = pkg.header.id
    local client = self:getClientById(clientId)
    client.pkg_count = client.pkg_count + 1
    client.total_arrive_ping = (client.total_arrive_ping + (socket.gettime() - pkg.header.time))
    client.average_arrive_ping = client.total_arrive_ping / client.pkg_count
end

function Server:getClientById(id)
    local index = self.clients[id]
    return self.clients[index]
end

return Server
