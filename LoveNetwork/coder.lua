local path = string.match(..., "(.*%.).*$")
local utils = require(path .. 'utils')

coder = {
    schemes = {}
}

local sizeInt = 4 -- float or integer
local sizeDouble = 8
local function emptySpace(size)
    return string.rep(" ", size)
end

function coder:encode(dataTable, schemeId) 
    local scheme = self.schemes[schemeId]
    local encodedContent = ""

    for i = 1, #scheme do
        local item = scheme[i]
        local value = dataTable[item.key]

        if not value then
            local emptyItemSize = 0
            if item.type == 'string' then
                emptyItemSize = item.size
            elseif  item.type == 'integer' then
                emptyItemSize = sizeInt
            else
                emptyItemSize = sizeDouble
            end
            encodedContent = encodedContent .. emptySpace(emptyItemSize)

        elseif item.type == 'integer' then
            encodedContent = encodedContent .. love.data.pack('string', 'i', value)

        elseif item.type == 'float' then
            local encodedValue = love.data.pack('string', 'd', value)
            encodedContent = encodedContent .. encodedValue

        elseif item.type == 'string' then
            value = tostring(value)
            if item.size < #value then
                error(item.key .. ' from scheme ' .. schemeId .. ' with is too big, maximum size expected ' .. item.size .. ' but received ' .. #value)
            end 

            encodedContent = encodedContent .. value .. emptySpace(math.abs(#value - item.size))

        elseif item.type == 'table' then
            local tableSize = #value
            encodedContent = encodedContent .. love.data.pack('string', 'i', tableSize)
            for j=1, tableSize do
                encodedContent = encodedContent .. self:encode(value[j], item.scheme)
            end
        end
    end

    return encodedContent
end

function coder:decode(data, schemeId)
    local scheme = self.schemes[schemeId]
    local decodedContent = {}
    local currDataPos = 1

    for i = 1, #scheme do
        local item = scheme[i]
        if item.type == 'integer' then
            local decodedValue = string.sub(data, currDataPos, currDataPos + sizeInt - 1)
            if decodedValue ~= emptySpace(sizeInt) then
                decodedContent[item.key] = love.data.unpack('i', decodedValue)
            end
            currDataPos = currDataPos + sizeInt

        elseif item.type == 'float' then
            local decodedValue = string.sub(data, currDataPos, currDataPos + sizeDouble - 1)
            if decodedValue ~= emptySpace(sizeDouble) then
                decodedContent[item.key] = love.data.unpack('d', decodedValue)
            end
            currDataPos = currDataPos + sizeDouble

        elseif item.type == 'string' then
            local decodedValue = string.sub(data, currDataPos, currDataPos + item.size - 1)
            if decodedValue ~= emptySpace(item.size) then
                decodedContent[item.key] = decodedValue:gsub(" ", "")
            end
            currDataPos = currDataPos + item.size

        elseif item.type == 'table' then
            local tableSizeString = string.sub(data, currDataPos, currDataPos + sizeInt - 1)
            local tableSize = love.data.unpack('i', tableSizeString)
            currDataPos = currDataPos + 4
            
            decodedContent[item.key] = {}
            for j=1, tableSize do
                local childScheme = self.schemes[item.scheme]
                local childData = string.sub(data, currDataPos, currDataPos + childScheme.totalSize)
                decodedContent[item.key][j] = self:decode(childData, item.scheme)
                currDataPos = currDataPos + childScheme.totalSize
            end
        end
    end

    return decodedContent
end

return coder