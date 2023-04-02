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
    self.entities = {}
    self.event_triggers = {}
    self.pending_messages = {}
    self.tickRate = 1/tickRate
    self.start_time = 0
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
    if message then
        table.insert(self.pending_messages, message)
    end

    self:processMessages()
end

function Server:processMessages()
    local current_time = os.clock()
    local elapsed_time = current_time - self.start_time

    if elapsed_time >= self.tickRate then
        for _, message in ipairs(self.pending_messages) do
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
        self.pending_messages = {}
        self.start_time = current_time
    end
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