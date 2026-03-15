if GetTime == nil then
    local socket = require('socket')
    GetTime = function(_)
        local realTime = socket.gettime()
        return realTime
    end
end

import 'Timer/Timer.lua'

RtaTimer = {
    -- timer: Timer,

    -- StartingSystemTime: number,
    -- Cycle: number,
    -- PreviousWorldTime: number,
}

function RtaTimer:new(args)
    args = args or {}

    local o = Timer:new(args)
    o.StartingSystemTime = args.startingSystemTime or nil
    o.Cycle = args.cycle or nil
    o.PreviousWorldTime = args.previousWorldTime or nil

    setmetatable(o, self)
    self.__index = self
    return o
end

--- Start the timer.
-- @param startingOffset The time to start the timer from. If nil, it will start at 0.
function RtaTimer:start(startingOffset)
    self:init()
    Timer.start(self, startingOffset)
end

function RtaTimer:init()
    self.Cycle = 0
    self.PreviousWorldTime = _worldTime
    self.StartingSystemTime = GetTime({})
end

function RtaTimer:getTime()
    return Timer.getTime(self)
end

--- Set the current time for the timer, which is the time that the timer will start from.
-- @param time The time to start the timer from. If nil, it will start at 0.
function RtaTimer:setTime(time)
    Timer.setTime(self, time)

    if self.Running then
        self.PreviousWorldTime = _worldTime
    end
end

--- Start the timer from the current elapsed time.
function RtaTimer:resume()
    Timer.resume(self)
end

--- Leave the timer running, but do not increment
function RtaTimer:pause()
    Timer.pause(self)
end
--- Stop the timer.
function RtaTimer:stop()
    Timer.stop(self)
end

--- Reset the timer to zero and set WasReset to true.
--- WasReset allows Livesplit to know if the timer was reset.
function RtaTimer:reset()
    Timer.reset(self)

    self.StartingSystemTime = nil
    self.Cycle = nil
    self.PreviousWorldTime = nil

    self.ElapsedTime = 0
end

--- Update the timer. This should be called every frame.
function RtaTimer:update()
    if not self.Running then
        return
    end

    if self.Paused then
        return
    end
    if self.Cycle < 30 then
        self.Cycle = self.Cycle + 1
        self:processWorldTime()
        return
    end

    self.Cycle = 0
    self:trueUp()
end

function RtaTimer:processWorldTime()
    local elapsedThisCycle = _worldTime - self.PreviousWorldTime
    self:setTime(self.ElapsedTime + elapsedThisCycle)
    self.PreviousWorldTime = _worldTime
end

function RtaTimer:trueUp()
    self.PreviousWorldTime = _worldTime
    self.ElapsedTime = GetTime({}) - self.StartingSystemTime
end

return RtaTimer
