local path = string.match(..., "(.*%.).*$")
local class = require(path .. 'class')
local bitwise = require("bit")

Bitfield = class('Bitfield')

function Bitfield:init()
    self.value = 0
end

function Bitfield:turnOn(bit)
    local mask = bitwise.rol(1, bit - 1)
    self.value = bitwise.bor(self.value, 1)
end

function Bitfield:turnOff(bit)
    local mask = bitwise.bnot(bitwise.lshift(1, bit - 1))
    self.value = bitwise.band(self.value, mask)
end

function Bitfield:shiftLeft(offset)
    self.value = bitwise.rol(self.value, offset)
    self.value = bitwise.band(self.value, 0xFFFFFFFF)
end

function Bitfield:shiftRight()
    self.value = bitwise.rshift(self.value, 1)
end

function Bitfield:bitIsOn(bit)
    local mask = bitwise.lshift(1, bit - 1)
    return bitwise.band(self.value, mask) ~= 0
end

function Bitfield:binaryRepresentation()
    local binaryString = ""
    local numBits = 32  -- Número de bits (assumindo que estamos trabalhando com números de 32 bits)

    for i = numBits - 1, 0, -1 do
        local bitValue = bitwise.band(bitwise.rshift(self.value, i), 1)
        binaryString = binaryString .. bitValue
    end

    return binaryString
end

function Bitfield:printBinaryRepresentation()
    print("Binary Representation:", self:binaryRepresentation())
end

return Bitfield