PlayerResult = {
    time = nil,
    maxSpeed = nil,
    vehicleName = nil,
}

function PlayerResult:new(init)
    local new = init or {
        time = nil,
        maxSpeed = nil,
        vehicleName = nil,
    }

    setmetatable(new, self)
    self.__index = self
    return new
end

function PlayerResult:copyWith(values)
    return PlayerResult:new({
        time = values.time or self.time,
        maxSpeed = values.maxSpeed or self.maxSpeed,
        vehicleName = values.vehicleName or self.vehicleName,
    })
end

