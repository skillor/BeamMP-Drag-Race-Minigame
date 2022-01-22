--- general purpose ui message for a player. TODO more customization
--- example of how to send:
--- { <-- wrap this beast in json.encode and voilà
----     visible = true, <-- set this to false and `null` to the rest to hide it on client side
----     header = 'This is a header',
----     messages = { 'Line #1', 'Line #2', ... },
----     buttons = {
----         {
----             icon = 'play_arrow',
----             text = 'play',
----             action = 'mpGameModes_dragRace.accept()' <-- some call to client lua
----         },
----         {
----             icon = 'close',
----             text = 'close',
----             action = '%CLOSE%' <-- this exact call closes the client-side ui pop-up.
----                                    Could've been something more clever but this also works
----         },
----         ....
----     }
---- }

BeamMPMessage = {
    visible = false, -- bool
    header = nil,    -- String
    messages = {},   -- List<String>
    buttons = {},    -- List<BeamMPMessageButton>
}

function BeamMPMessage:new(init)
    local new = init or {
        visible = false,
        header = nil,
        messages = {},
        buttons = {},
    }

    setmetatable(new, self)
    self.__index = self
    return new
end

function BeamMPMessage:DSQPseudoVictory()
    return BeamMPMessage:new({
        visible = true,
        header = 'The other player was disqualified',
        messages = {'You basically won', 'Breaking the rules is bad!'},
        buttons = {
            BeamMPMessageButton:new ({
                icon = 'close',
                text = 'close',
                action = '%CLOSE%',
            }),
        },
    })
end

function BeamMPMessage:DSQRaceTimeout()
    return BeamMPMessage:new({
        visible = true,
        header = 'You are out of time',
        messages = {'How are you so slow???'},
        buttons = {
            BeamMPMessageButton:new ({
                icon = 'close',
                text = 'close',
                action = '%CLOSE%',
            }),
        },
    })
end

function BeamMPMessage:DSQPrestageTimeout()
    return BeamMPMessage:new({
        visible = true,
        header = 'You are out of time',
        messages = {'You didn\'t show up at the start line within time limit'},
        buttons = {
            BeamMPMessageButton:new ({
                icon = 'close',
                text = 'close',
                action = '%CLOSE%',
            }),
        },
    })
end

function BeamMPMessage:DSQJumpstart()
    return BeamMPMessage:new({
        visible = true,
        header = 'You jumpstarted',
        messages = {'Hold your horses, cowboy!'},
        buttons = {
            BeamMPMessageButton:new ({
                icon = 'close',
                text = 'close',
                action = '%CLOSE%',
            }),
        },
    })
end

function BeamMPMessage:MPVictoryMessage(winningResult, losingResult)
    return BeamMPMessage:new({
        visible = true,
        header = 'You won!',
        messages = {
            'Nice driving!',
            'You were driving '..winningResult.vehicleName..' and finished in '..winningResult.time..' s',
            'Your opponent was driving '..losingResult.vehicleName..' and finished in '..losingResult.time..' s',
        },
        buttons = {
            BeamMPMessageButton:new ({
                icon = 'close',
                text = 'YAY!',
                action = '%CLOSE%',
            }),
        },
    })
end

function BeamMPMessage:MPDefeatMessage(winningResult, losingResult)
    return BeamMPMessage:new({
        visible = true,
        header = 'You lost!',
        messages = {
            'Better luck next time!',
            'You were driving '..losingResult.vehicleName..' and finished in '..losingResult.time..' s',
            'Your opponent was driving '..winningResult.vehicleName..' and finished in '..winningResult.time..' s',
        },
        buttons = {
            BeamMPMessageButton:new ({
                icon = 'close',
                text = 'close',
                action = '%CLOSE%',
            }),
        },
    })
end

--- a really niche scenario, but who knows,
--- maybe once in a lifetime this will happen
function BeamMPMessage:MPDraw(player1Result, player2Result)
    return BeamMPMessage:new({
        visible = true,
        header = 'It\'s a draw!',
        messages = {
            'What a race! Unbelievable!',
            'You were driving '..player1Result.vehicleName,
            'Your opponent was driving '..player2Result.vehicleName,
            'You both finished in'..player1Result.time..'! Incredible!',
        },
        buttons = {
            BeamMPMessageButton:new ({
                icon = 'close',
                text = 'WOW!',
                action = '%CLOSE%',
            }),
        },
    })
end

function BeamMPMessage:SPResult(playerResult)
    return BeamMPMessage:new({
        visible = true,
        header = 'Nice driving!',
        messages = {
            'You were driving '..playerResult.vehicleName..' and finished in '..playerResult.time..' s',
        },
        buttons = {
            BeamMPMessageButton:new ({
                icon = 'close',
                text = 'awesome!',
                action = '%CLOSE%',
            }),
        },
    })
end

function BeamMPMessage:Invite(inviter, rawJson)
    return BeamMPMessage:new({
        visible = true,
        header = 'Drag Race Invite!',
        messages = {
            'Player '.. inviter.username..' invites you to a drag race!',
            inviter.username..' is driving '.. inviter.vehicle.name,
        },
        buttons = {
            BeamMPMessageButton:new ({
                icon = 'play_arrow',
                text = 'accept',
                action = "mpGameModes_dragRace_dragRace.acceptInvite('".. rawJson .."')",
            }),
            BeamMPMessageButton:new ({
                icon = 'close',
                text = 'decline',
                action = "mpGameModes_dragRace_dragRace.rejectInvite('".. rawJson .."')",
            }),
        },
    })
end

BeamMPMessageButton = {
    icon = nil,   --String
    text = nil,   --String
    action = nil, --String
}

function BeamMPMessageButton:new(init)
    local new = init or {
        icon = nil,
        text = nil,
        action = nil,
    }

    setmetatable(new, self)
    self.__index = self
    return new
end
