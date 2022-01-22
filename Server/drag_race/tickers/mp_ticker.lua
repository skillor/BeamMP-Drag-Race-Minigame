require('state/global_state_handler')
require('models/race_state')
require('models/player_state')
require('models/counters')

local CONSTANTS = require('util/constants')
local flowControl = require('flow_control/flow_control')

local function tick()
    local status1 = state.player1State.status
    local status2 = state.player2State.status

    if status1 == PlayerStatus.prestaging
            or status2 == PlayerStatus.prestaging then

        local counter = state.counters.prestageCounter

        if counter == CONSTANTS.PRESTAGE_TIME_LIMIT then
            if status1 == PlayerStatus.ready
                    and status2 == PlayerStatus.prestaging then
                flowControl.disqualify(
                        state.player2State.id,
                        DSQReason.prestageTimeout
                )
                flowControl.sendDSQVictoryMessage(
                        state.player1State.id
                )
            elseif status1 == PlayerStatus.ready
                    and status2 == PlayerStatus.prestaging then
                flowControl.disqualify(
                        state.player1State.id,
                        DSQReason.prestageTimeout
                )
                flowControl.sendDSQVictoryMessage(
                        state.player2State.id
                )
            else
                flowControl.emit(RaceState:new({
                   raceType = RaceType.none,
                   player1State = state.player1State:copyWith({
                       status = PlayerStatus.disqualified,
                   }),
                   player2State = PlayerState:new({
                       status = PlayerStatus.disqualified,
                   }),
                   counters = Counters:new(),
                }))
                local network = require('network/network')
                network.sendUIMessageToPlayer(
                        state.player1State.id,
                        BeamMPMessage:DSQPrestageTimeout()
                )
                network.sendUIMessageToPlayer(
                        state.player2State.id,
                        BeamMPMessage:DSQPrestageTimeout()
                )
            end
        else
            flowControl.emit(state:copyWith({
                counters = state.counters:copyWith({
                    prestageCounter = counter + 1
                })
            }))
        end
    end

    if status1 == PlayerStatus.ready and status2 == PlayerStatus.ready then
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
                player2State = state.player2State:copyWith({
                    status = PlayerStatus.racing
                }),
            }))
        end
    end

    if status1 == PlayerStatus.racing and status2 == PlayerStatus.racing then
        local counter = state.counters.raceCounter

        if counter == CONSTANTS.RACE_TIME_LIMIT then
            flowControl.disqualify(
                    state.player1State.id,
                    DSQReason.raceTimeout
            )
            flowControl.disqualify(
                    state.player2State.id,
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
    tick = tick,
}
