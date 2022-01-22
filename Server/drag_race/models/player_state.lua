require('util/enum')
require('models/result')

PlayerStatus = enum({'prestaging', 'ready', 'racing', 'disqualified', 'none'})

PlayerState = {
    id = -1,
    status = PlayerStatus.none,
    result = PlayerResult:new(),
}

function PlayerState:new(init)
    local new = init or {
        id = -1,
        status = PlayerStatus.none,
        result = PlayerResult:new(),
    }

    setmetatable(new, self)
    self.__index = self
    return new
end

function PlayerState:toJson()
    return {
        id = self.id,
        status = self.status.name,
        result = self.result,
    }
end

function PlayerState:copyWith(values)
    return PlayerState:new({
        id = values.id or self.id,
        status = values.status or self.status,
        result = values.result or self.result,
    })
end

function PlayerState:equals(other)
    return self == other or self.id == other.id
            and self.status.name == other.status.name
            and self.result == other.result
end
