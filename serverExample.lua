LoveNetwork = require('LoveNetwork')
local server = LoveNetwork:newServer('localhost', '8080', 10)

server:on('connect', function (data, client)
    print(data.sender .. ' connected')
end)

while true do
    server:update()
end