local path = string.match(..., "(.*%.).*$")
local class = require(path .. 'class')
local utils = require(path .. 'utils')
local socket = require('socket')

Client = class('Client')

function Client:init(server_address, server_port, id)
    self.socket = socket:udp()
    self.socket:setpeername(server_address, server_port)
    self.socket:settimeout(0)

    self.id = id
    self.pending_messages = {}
    self.events = {}
    self.event_triggers = {}
end

function Client:update()
    repeat
        local data, msg = self.socket:receive()
        if data then
            local message = utils:decode(data)
            if utils:isValidMessage(message) then self:callEventTrigger(message) end
        end
    until not data
end

function Client:send(event, content)
    local message = {sender = self.id, event = event, content = content}

    if not self.pending_messages[event] then
        self.pending_messages[event] = {}
        self.pending_messages[event].last_message_sent = 0
    end

    table.insert(self.pending_messages[event], message)
    message.sequence_number = #self.pending_messages[event]

    local encoded_message = utils:encode(message)
    self.socket:send(encoded_message)
end

function Client:callEventTrigger(message)
    local trigger = self.event_triggers[message.event]
    if trigger then
        trigger(message)
    end
end

function Client:on(event, trigger)
    self.event_triggers[event] = trigger
end

function Client:connect()
    self:send('connect')
end

function Client:disconnect()
    self:send('disconnect')
end

return Client