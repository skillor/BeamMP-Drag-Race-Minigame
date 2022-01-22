require('state/global_state_handler')
require('models/race_state')
require('models/player_state')
require('models/counters')

local CONSTANTS = require('util/constants')
local flowControl = require('flow_control/flow_control')

local function tick()
    local status = state.player1State.status

    if status == PlayerStatus.prestaging then
        local counter = state.counters.prestageCounter

        if counter == CONSTANTS.PRESTAGE_TIME_LIMIT then
            flowControl.disqualify(
                    state.player1State.id,
                    DSQReason.prestageTimeout
            )
        else
            flowControl.emit(state:copyWith({
                counters = state.counters:copyWith({
                    prestageCounter = counter + 1
                })
            }))
        end
    end

    if status == PlayerStatus.ready then
        -- this is a special case where we count downwards
        local counter = state.counters.countdownCounter

        flowControl.emit(state:copyWith({
            counters = state.counters:copyWith({
                countdownCounter = counter - 1
            })
        }))

        if counter == 1 then
            flowControl.emit(state:copyWith({
                player1State = state.player1State:copyWith({
                    status = PlayerStatus.racing
                }),
            }))
        end
    end

    if status == PlayerStatus.racing then
        local counter = state.counters.raceCounter

        if counter == CONSTANTS.RACE_TIME_LIMIT then
            flowControl.disqualify(
                    state.player1State.id,
                    DSQReason.raceTimeout
            )
        else
            flowControl.emit(state:copyWith({
                counters = state.counters:copyWith({
                    raceCounter = counter + 1
                })
            }))
        end
    end
end

return {
    tick = tick
}