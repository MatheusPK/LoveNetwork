local path = string.match(..., "(.*%.).*$")
local class = require(path .. 'class')
local utils = require(path .. 'utils')
local socket = require('socket')

local Server = class('Server')

function Server:init(host, port, tickRate)
    self.socket = socket:udp()
    self.socket:setsockname(host, port)
    self.socket:settimeout(0)

    self.clients = {}
    self.event_triggers = {}
    self.tickRate = 1 / tickRate
end

function Server:update()
    local data, ip, port = self.socket.receivefrom()
    if data then
        local message = utils:decode(data)  -- Message pattern -> {sender = sender, event = event, content = content, sequence_number = sequence_number}
        if not utils:isValidMessage(message) then return end

        if message.event == 'connect' then 
            self:newClient(message.sender, ip, port)
        end

        if message.event == 'disconnect' then
            self:removeClient(message.sender)
        end

        self:callEventTrigger(message)
        self:broadcast(data)
    end
end

function Server:newClient(id, ip, port)
    local newClient = {id = id, ip = ip, port = port}
    table.insert(self.clients, newClient)
    self.clients[id] = #self.clients
end

function Server:removeClient(id)
    local lastClientIndex = #self.clients
    utils:swap(self.clients, self.clients[id], lastClientIndex)
    table.remove(self.clients, lastClientIndex)
end

function Server:broadcast(data)
    for _, client in ipairs(self.clients) do
        self:sendTo(client, data)
    end
end

function Server:callEventTrigger(message)
    local client = self.clients[message.sender]
    local trigger = self.event_triggers[message.event]
    if client and trigger then
        trigger(message, client)
    end
end

function Server:sendEventTo(client, event, content)
    local message = {sender = 'SERVER', event = event, content = content}
    local encoded_message = utils:encode(message)
    self.socket:sendTo(client, encoded_message)
end

function Server:sendTo(client, data)
    self.socket:sendto(data, client.ip, client.port)
end

function Server:on(event, trigger)
    self.event_triggers[event] = trigger
end

return Server
