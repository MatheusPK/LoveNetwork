LoveNetwork = require('LoveNetwork')
local client = LoveNetwork:newClient('localhost', '8080', 'matheus')

client:connect()

client:on('connect', function (data)
    print(data.sender .. ' connected')
end)

while true do
    client:update()
end