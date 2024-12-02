local path = string.match(..., "(.*%.).*$")
local class = require(path .. 'class')
local utils = require(path .. 'utils')

local Package = class('Package')

local compressAlg = 'zlib'
local compressLevel = 9
local encoderSeparator = 'HEA'

function Package:init(id, sequence, ack, ack_bitfield, event, content)
    self.header = {
        id = id,
        sequence = sequence,
        ack = ack,
        ack_bitfield = ack_bitfield,
        event = event,
        time = 0
    }

    self.content = content or nil
end

function Package:encode(time)
    self.header.time = time
    local header = self.header
    local content = self.content
    local data = header.id .. encoderSeparator .. header.sequence .. encoderSeparator .. header.ack .. encoderSeparator .. header.ack_bitfield .. encoderSeparator .. header.event .. encoderSeparator .. header.time .. encoderSeparator .. content
    return love.data.compress('string', compressAlg, data, compressLevel)
end

function Package:decode(data)
    local decompressedData = love.data.decompress('string', compressAlg, data)
    local decodedData = utils:split(decompressedData, encoderSeparator)

    local id = decodedData[1]
    local sequence = tonumber(decodedData[2])
    local ack = tonumber(decodedData[3])
    local ack_bitfield = tonumber(decodedData[4])
    local event = decodedData[5]
    local time = decodedData[6]
    local content = decodedData[7] or {}

    local pkg = Package(id, sequence, ack, ack_bitfield, event, content)
    pkg.header.time = time

    return pkg
end

function Package:isValid()
    return self.header.id and self.header.sequence and self.header.ack and self.header.ack_bitfield and self.header.event
end

return Package