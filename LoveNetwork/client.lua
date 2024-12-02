local path = string.match(..., "(.*%.).*$")
local class = require(path .. 'class')
local package = require(path .. 'package')
local utils = require(path .. 'utils')
local bitfield = require(path .. 'bitfield')
local coder = require(path .. 'coder')
local socket = require('socket')

Client = class('Client')

function Client:init(server_address, server_port, id)
    self.socket = socket:udp()
    self.socket:setpeername(server_address, server_port)
    self.socket:settimeout(0)

    self.id = id
    self.sent_event_triggers = {}
    self.incoming_event_triggers = {}

    -- server packages controle
    self.lastServerSequence = 0
    -- sent packages control
    self.local_sequence = 0
    self.remote_sequence = 0
    self.ack_bitfield = bitfield()
    self.lost_packages = 0

    -- latency
    self.latency = 0
    self.total_arrive_ping = 0
    self.average_arrive_ping = 0
    self.received_pkg_count = 0
end

function Client:update(dt)
    repeat
        local data, msg = self.socket:receive()
        if data then
            local pkg = package:decode(data)
            if pkg:isValid() then
                pkg.content = coder:decode(pkg.content, pkg.header.event)
                if pkg.header.sequence > self.lastServerSequence then
                    self:setLatency(pkg)
                    self:setAck(pkg)
                    self.lastServerSequence = pkg.header.sequence
                    self:callEventTrigger(pkg, self.incoming_event_triggers)
                end
            end
        end
    until not data
end

function Client:send(event, content)
    self.local_sequence = self.local_sequence + 1

    local pkg = package(
        self.id,
        self.local_sequence,
        self.remote_sequence,
        0,
        event,
        coder:encode(content, event)
    )

    self:callEventTrigger(pkg, self.sent_event_triggers)

    local encoded_package = pkg:encode(socket.gettime())
    self.socket:send(encoded_package)
end

function Client:callEventTrigger(pkg, event_triggers)
    local trigger = event_triggers[pkg.header.event]
    if trigger then
        trigger(pkg)
    end
end

function Client:onReceive(event, trigger)
    self.incoming_event_triggers[event] = trigger
end

function Client:onSend(event, trigger)
    self.sent_event_triggers[event] = trigger
end

function Client:connect()
    self:send(NETWORK_EVENTS.CONNECT)
end

function Client:disconnect()
    -- self:send(NETWORK_EVENTS.DISCONNECT)
end

function Client:registerScheme(event, scheme)
    coder.schemes[event] = scheme
end

function Client:setAck(pkg)
    local worldState = pkg.content

    local lastAck = worldState.ack
    local ack_bitfield = worldState.ack_bitfield

    if lastAck > self.remote_sequence then
        self.remote_sequence = lastAck
        self.ack_bitfield.value = ack_bitfield
    end
end

function Client:setLatency(pkg)
    self.received_pkg_count = self.received_pkg_count + 1
    self.total_arrive_ping = (self.total_arrive_ping + (socket.gettime() - pkg.header.time))
    self.average_arrive_ping = self.total_arrive_ping/self.received_pkg_count

    if self.received_pkg_count > 20 then
        self.received_pkg_count = 0
        self.total_arrive_ping = self.average_arrive_ping
    end
end

function Client:gettime()
    return socket.gettime()
end

return Client