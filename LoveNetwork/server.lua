local path = string.match(..., "(.*%.).*$")
local class = require(path .. 'class')
local utils = require(path .. 'utils')
local socket = require('socket')

local Server = class('Server')

function Server:init(host, port)
    self.socket = socket:udp()
    self.socket:setsockname(host, port)
    self.socket:settimeout(0)
    self.clients = {}
    self.entities = {}
    self.event_triggers = {}
end

function Server:sendTo(client, data)
    self.socket:sendto(data, client.ip, client.port)
end

function Server:receive()
    local data, sender_ip, sender_port = self.socket:receivefrom()
    if data and sender_ip and sender_port then
        local message = utils:decode(data) -- '{sender = sender, event = event, content = content, sequence_number = sequence_number}'
        message.sender_ip = sender_ip ; message.sender_port = sender_port
        return message
    end
    return nil
end

function Server:update()
    local message = self:receive()

    if not message then return end

    if message.event == 'connect' then
        local newClient = {id = message.sender, ip = message.sender_ip, port = message.sender_port}
        for _, client in ipairs(self.clients) do
            local connectMessage = {sender = client.id, event = 'connect', content = nil, sequence_number = 0}
            self:sendTo(newClient, utils:encode(connectMessage))
        end
        table.insert(self.clients, newClient)
        self.clients[newClient.id] = #self.clients

    elseif message.event == 'disconnect' then
        local lastClientIndex = #self.clients
        utils:swap(self.clients, self.clients[message.sender], lastClientIndex)
        table.remove(self.clients, lastClientIndex)
    end

    local trigger = self.event_triggers[message.event]
    if trigger then trigger(message) end

    self:broadcast(message)
end

function Server:broadcast(message)
    local data = utils:encode(message)
    for _, client in ipairs(self.clients) do
        self:sendTo(client, data)
    end
end

function Server:on(event, trigger)
    self.event_triggers[event] = trigger
end

return Server