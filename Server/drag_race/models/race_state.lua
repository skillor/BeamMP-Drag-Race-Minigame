require('util/enum')
require('models/player_state')
require('models/counters')

RaceType = enum({'MP', 'SP', 'none'})

-- We make everything non-nil to ensure that there are
-- no `NullPointerException`s and that `copyWith` works as expected.
RaceState = {
    raceType = RaceType.none,
    player1State = PlayerState:new(),
    player2State = PlayerState:new(),
    counters = Counters:new(),
}

function RaceState:new(init)
    local new = init or {
        raceType = RaceType.none,
        player1State = PlayerState:new(),
        player2State = PlayerState:new(),
        counters = Counters:new(),
    }

    setmetatable(new, self)
    self.__index = self
    return new
end

function RaceState:toJson()
    return {
        raceType = self.raceType.name,
        player1State = self.player1State:toJson(),
        player2State = self.player2State:toJson(),
        counters = self.counters,
    }
end

function RaceState:copyWith(values)
    return RaceState:new({
        raceType = values.raceType or self.raceType,
        player1State = values.player1State or self.player1State,
        player2State = values.player2State or self.player2State,
        counters = values.counters or self.counters,
    })
end

function RaceState:equals(other)
    return self == other or self.raceType.name == other.raceType.name
            and self.player1State:equals(other.player1State)
            and self.player2State:equals(other.player2State)
            and self.counters:equals(other.counters)
end
