local class      = {}
local baseMt     = {}
local _instances = setmetatable({},{__mode = 'k'})
local _classes   = setmetatable({},{__mode = 'k'})

baseMt = {
    __call = function(self, ...) return self:new(...) end,
    __tostring = function(self)
        if self.isInstance then
            return string.format("Instance of '%s' (%s)", self.name or '?', _instances[self])
        else 
            return string.format("Class '%s' (%s)", self.name or '?', _classes[self])
        end
     end
}

local function deep_copy(t, dest, aType)
	t = t or {}
	local r = dest or {}
	for k,v in pairs(t) do
		if aType ~= nil and type(v) == aType then
			r[k] = (type(v) == 'table')
							and ((_classes[v] or _instances[v]) and v or deep_copy(v))
							or v
		elseif aType == nil then
			r[k] = (type(v) == 'table') 
			        and k~= '__index' and ((_classes[v] or _instances[v]) and v or deep_copy(v)) 
							or v
		end
	end
	return r
end

local function instantiate(self, ...)
    assert(not self.isInstance, "Wrong method call. Expected class:new(...) or class(...)")
    local instance = {}
    _instances[instance] = tostring(instance)
    instance.__index = nil
    instance.isInstance = true
    if self.init then self.init(instance, ...) end
    return setmetatable(instance, self)
end

local function extend(self, name, extra_params)
    assert(not self.isInstance, "extend(...)")
    local heir = extra_params or {}
    _classes[heir] = tostring(heir)
    self.__subclasses[heir] = true
    deep_copy(self, heir)
	heir.name    = name
	heir.__index = heir
	heir.super   = self
	return setmetatable(heir,self)
end

function class:new(name, attr)
    local o = attr or {}

    _classes[o] = tostring(o)

    o.name = name or o.name
    o.__index = o

    o.new = instantiate
    o.extend = extend
    o.__call = baseMt.__call
    o.__tostring = baseMt.__tostring
    o.__subclasses = setmetatable({},{__mode = 'k'})
    return setmetatable(o, baseMt)
end

return setmetatable(class, {__call = function(self, ...) return self:new(...) end})