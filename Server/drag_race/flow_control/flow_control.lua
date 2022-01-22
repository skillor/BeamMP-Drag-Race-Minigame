require('state/global_state_handler')
require('ui/messages/messages')

require('models/race_state')
require('models/player_state')
require('models/counters')
require('models/result')
require('models/dsq')

local network = require('network/network')
local stateManager = require('state/global_state_handler')

local function startSPRace(playerId)
    -- create a new raceState, to emphasize
    -- that we want to start routine from scratch
    stateManager.emit(RaceState:new({
        raceType = RaceType.SP,
        player1State = PlayerState:new({
            id = tonumber(playerId),
            status = PlayerStatus.prestaging,
        }),
        player2State = PlayerState:new(),
        counters = Counters:new(),
    }))
end

local function startMPRace(data)
    -- create a new raceState, to emphasize
    -- that we want to start routine from scratch
    stateManager.emit(RaceState:new({
        raceType = RaceType.MP,
        player1State = PlayerState:new({
            id = tonumber(data.id1),
            status = PlayerStatus.prestaging,
        }),
        player2State = PlayerState:new({
            id = tonumber(data.id2),
            status = PlayerStatus.prestaging,
        }),
        counters = Counters:new(),
    }))
end

local function onPlayerPrestageReady(playerId)
    if (tonumber(playerId) == state.player1State.id) then
        stateManager.emit(state:copyWith({
            player1State = state.player1State:copyWith({
                status = PlayerStatus.ready,
            })
        }))
    elseif (tonumber(playerId) == state.player2State.id) then
        stateManager.emit(state:copyWith({
            player2State = state.player2State:copyWith({
                status = PlayerStatus.ready,
            })
        }))
    end
end

local function sendDSQVictoryMessage(playerId)
    network.sendUIMessageToPlayer(
            playerId,
            BeamMPMessage:DSQPseudoVictory()
    )
end

local function disqualify(playerId, reason)
    if (tonumber(playerId) == state.player1State.id) then
        stateManager.emit(state:copyWith({
            raceType = RaceType.none,
            player1State = state.player1State:copyWith({
                status = PlayerStatus.disqualified,
            }),
            counters = Counters:new(),
        }))
    elseif (tonumber(playerId) == state.player2State.id) then
        stateManager.emit(state:copyWith({
            raceType = RaceType.none,
            player2State = state.player2State:copyWith({
                status = PlayerStatus.disqualified,
            }),
            counters = Counters:new(),
        }))
    end

    if reason == DSQReason.prestageTimeout then
        network.sendUIMessageToPlayer(playerId, BeamMPMessage:DSQPrestageTimeout())
    elseif reason == DSQReason.raceTimeout then
        network.sendUIMessageToPlayer(playerId, BeamMPMessage:DSQRaceTimeout())
    elseif reason == DSQReason.jumpstart then
        network.sendUIMessageToPlayer(playerId, BeamMPMessage:DSQJumpstart())
    end
end

local function mpOutcome()
    if state.player1State.result.time == nil
            or state.player2State.result.time == nil then return end

    stateManager.emit(state:copyWith({
        raceType = RaceType.none,
        counters = Counters:new(),
    }))

    -- both players finished normally.
    if state.player1State.result.time == state.player2State.result.time then
        network.sendUIMessageToPlayer(
                state.player1State.id,
                BeamMPMessage:MPDraw(
                        state.player1State.result,
                        state.player2State.result
                )
        )
        network.sendUIMessageToPlayer(
                state.player2State.id,
                BeamMPMessage:MPDraw(
                        state.player2State.result,
                        state.player1State.result
                )
        )
    elseif state.player1State.result.time < state.player2State.result.time then
        network.sendUIMessageToPlayer(
                state.player1State.id,
                BeamMPMessage:MPVictoryMessage(
                        state.player1State.result,
                        state.player2State.result
                )
        )
        network.sendUIMessageToPlayer(
                state.player2State.id,
                BeamMPMessage:MPDefeatMessage(
                        state.player1State.result,
                        state.player2State.result
                )
        )
    else
        network.sendUIMessageToPlayer(
                state.player1State.id,
                BeamMPMessage:MPDefeatMessage(
                        state.player1State.result,
                        state.player2State.result
                )
        )
        network.sendUIMessageToPlayer(
                state.player2State.id,
                BeamMPMessage:MPVictoryMessage(
                        state.player1State.result,
                        state.player2State.result
                )
        )
    end
end

local function spOutcome()
    stateManager.emit(state:copyWith({
        raceType = RaceType.none,
        counters = Counters:new(),
    }))

    network.sendUIMessageToPlayer(
            state.player1State.id,
            BeamMPMessage:SPResult(
                    state.player1State.result
            )
    )
end

local function handleOutcome()
    if state.raceType == RaceType.MP then
        mpOutcome()
    elseif state.raceType == RaceType.SP then
        spOutcome()
    end
end

local function markPlayerCrossedFinishLine(playerId, results)
    if (playerId == state.player1State.id) then
        stateManager.emit(state:copyWith({
            player1State = state.player1State:copyWith({
                status = PlayerStatus.none,
                result = PlayerResult:new(results),
            }),
        }))
    elseif (playerId == state.player2State.id) then
        stateManager.emit(state:copyWith({
            player2State = state.player2State:copyWith({
                status = PlayerStatus.none,
                result = PlayerResult:new(results),
            }),
        }))
    end

    handleOutcome()
end

local function emitState(state)
    stateManager.emit(state)
end

return {
    startSPRace = startSPRace,
    startMPRace = startMPRace,
    disqualify = disqualify,
    sendDSQVictoryMessage = sendDSQVictoryMessage,
    onPlayerPrestageReady = onPlayerPrestageReady,
    markPlayerCrossedFinishLine = markPlayerCrossedFinishLine,
    emit = emitState,
}
