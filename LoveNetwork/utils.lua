local utils = {}

function utils:split(inputString, delimiter)
    local parts = {}
    local start = 1

    while start <= #inputString do
        local delimiterStart, delimiterEnd = inputString:find(delimiter, start)
        
        if delimiterStart then
            table.insert(parts, inputString:sub(start, delimiterStart - 1))
            start = delimiterEnd + 1
        else
            -- If no more delimiters are found, add the remaining part of the string
            table.insert(parts, inputString:sub(start))
            break
        end
    end

    return parts
end

function utils:isValidMessage(message)
    return message.sender and message.event and message.sequence_number
end

function utils:swap(table, e1, e2)
    local pos1, pos2 = table[e1], table[e2]
    table[pos1], table[pos2] = table[pos2], table[pos1]
    table[e1], table[e2] = table[e2], table[e1]
end

function utils:tableToString(t)
    local string = "{"
    for k, v in pairs(t) do
        string = string .. ','
        local kaux = ""
        if type(k) == 'string' then
            kaux = k .. "="
        end
        if type(v) == 'table' then
            string = string .. kaux .. self:tableToString(v)
        elseif type(v) == 'string' then
            string = string .. kaux .. "'" .. v .. "'"
        elseif type(v) == 'boolean' then
            local value = v and 'true' or 'false'
            string = string .. kaux .. value
        else
            string = string .. kaux .. v
        end
    end
    string = string:gsub(",", "", 1)
    string = string .. "}"
    return string
end

function utils:pt(x, nocut, id, visited)
    visited = visited or {}
    id = id or ""
    if type(x) == "string" then
        return "'" .. tostring(x) .. "'"
    elseif type(x) ~= "table" then
        return tostring(x)
    elseif visited[x] and not nocut then
        return "..." -- cycle
    else
        visited[x] = true
        local s = id .. "{\n"
        for k, v in pairs(x) do
            s = s .. id .. tostring(k) .. " = " .. self:pt(v, nocut, id .. "  ", visited) .. ";\n"
        end
        s = s .. id .. "}"
        return s
    end
end

return utils
