local path = ... .. '.'
local Client   = require(path .. 'client')
local Server   = require(path .. 'server')


local LoveNetwork = {
    client  = Client,
    server  = Server,
}

function LoveNetwork:newClient(server_address, server_port, id)
    return Client(server_address, server_port, id)
end

function LoveNetwork:newServer(host, port, tickRate)
    return Server(host, port, tickRate)
end

return LoveNetwork