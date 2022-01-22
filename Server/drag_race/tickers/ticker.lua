require('state/global_state_handler')
require('models/race_state')

local mpTicker = require('tickers/mp_ticker')
local spTicker = require('tickers/sp_ticker')

local function tick()
    if (state.raceType == RaceType.MP) then
        mpTicker.tick()
    elseif (state.raceType == RaceType.SP) then
        spTicker.tick()
    end
end

return {
    tick = tick
}
