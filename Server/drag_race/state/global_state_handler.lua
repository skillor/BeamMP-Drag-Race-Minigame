require('models/race_state')
local network = require('network/network')

state = RaceState:new()

local function emit(newState)
    if state:equals(newState) then return end

    state = newState
    network.syncRaceState(state)
end

return {
    emit = emit
}
