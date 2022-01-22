local CONSTANTS = require('util/constants')

Counters = {
    prestageCounter = 0,
    countdownCounter = CONSTANTS.COUNTDOWN_TIMER,
    raceCounter = 0,
}

function Counters:new(init)
    local new = init or {
        prestageCounter = 0,
        countdownCounter = CONSTANTS.COUNTDOWN_TIMER,
        raceCounter = 0,
    }

    setmetatable(new, self)
    self.__index = self
    return new
end

function Counters:copyWith(values)
    return Counters:new({
        prestageCounter = values.prestageCounter or self.prestageCounter,
        countdownCounter = values.countdownCounter or self.countdownCounter,
        raceCounter = values.raceCounter or self.raceCounter,
    })
end

function Counters:equals(other)
    return self == other or self.prestageCounter == other.prestageCounter
            and self.countdownCounter == other.countdownCounter
            and self.raceCounter == other.raceCounter
end
