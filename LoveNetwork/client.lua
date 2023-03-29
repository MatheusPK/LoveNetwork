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
    self.current_sequence_number = 0
    self.event_triggers = {}
end

function Client:send(event, content)
    self.current_sequence_number = self.current_sequence_number + 1

    local message = {}
    message.sender = self.id
    message.event = event
    message.content = content
    message.sequence_number = self.current_sequence_number

    table.insert(self.pending_messages, message)

    local encoded_message = utils:encode(message)
    self.socket:send(encoded_message)
end

function Client:receive()
    local messages = {}

    repeat
        local data, msg = self.socket:receive()
        if data then
            local message = utils:decode(data)
            if utils:isValidMessage(message) then table.insert(messages, message) end
        end
    until not data

    return messages
end

function Client:update()
    local messages = self:receive()

    for _, message in ipairs(messages) do
        local trigger = self.event_triggers[message.event]
        if trigger then trigger(message) end
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