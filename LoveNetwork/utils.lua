local utils = {}

function utils:encode(message)
    local encodedMessage = self:tableToString(message)
    return encodedMessage
end

function utils:decode(data)
    local message = load('return ' .. data)()
    return message
end

function utils:isValidMessage(message)
    return message.sender and message.event and message.sequence_number
end

function utils:swap(table, e1, e2)
    local pos1, pos2 = table[e1], table[e2]
    table[pos1], table[pos2] = table[pos2], table[pos1]
    table[e1], table[e2] = table[e2], table[e1]
end

function utils:tableToString(table)
    local str = "{"
    for k, v in pairs(table) do
      if type(v) == "table" then
        str = str .. k .. " = " .. self:tableToString(v) .. ","
      elseif type(v) == "string" then
        str = str .. k .. " = \"" .. v .. "\","
      else
        str = str .. k .. " = " .. tostring(v) .. ","
      end
    end
    str = str .. "}"
    return str
  end

function utils:printMessage(message)
    print('message = {')
    self:printTable(message, 2)
    print('}')
end

function utils:printTable(table, indent)
    if not indent then
      indent = 0
    end

    for k, v in pairs(table) do
      if type(v) == "table" then
        print(string.rep("  ", indent) .. k .. " = {")
        self:printTable(v, indent + 1)
        print(string.rep("  ", indent) .. "},")
      else
        print(string.rep("  ", indent) .. k .. " = " .. tostring(v) .. ",")
      end
    end
  end



return utils