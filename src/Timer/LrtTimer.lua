--- LrtTimer is used to track load-removed time.
-- Normally, speedruns are tracked in real-time (RTA), or in-game time (IGT).
-- However, games do not run identically on all systems, which means load times can have
-- a significant impact on RTA. LRT (load-removed time) attempts to mitigate this by pausing
-- the timer during loading screens.
--
-- This implementation of LRT uses two timers: one RtaTimer for real-time, and one regular Timer to track time spent on load screens.
-- The load times are managed by LrtTimer, and upon finishing a load, the LoadTimer is updated. When requesting the time, the LoadTimer
-- is subtracted from the RealTimer to get the LRT.
--
-- Because we often are interested in running a real-time timer alongside LRT, this implementation
-- allows for the real-time timer to be passed in, so we don't need to duplicate the tracking of real time.
--
-- Also, while RtaTimer might "predict" elapsed time based on world time with occasional true-ups,
-- LRT cannot do that accurately because it can stop and start at any time. Therefore, LRT will grab
-- system time each time a LoadEvent occurs to ensure accuracy.
import 'Timer/RtaTimer.lua'
import 'Timer/Timer.lua'

LrtTimer = {
    Running = false,
    Loading = false,
    WasReset = false,

    ---type RtaTimer
    RealTimer = RtaTimer:new(),
    ---type RtaTimer
    LoadTimer = Timer:new(),
}

function LrtTimer:new(args)
    args = args or {}
    local o = {
        Running = false,

        RealTimer = args.withRtaTimer or RtaTimer:new(),
        LoadTimer = Timer:new(),
    }
    setmetatable(o, self)
    self.__index = self
    return o
end

function LrtTimer:init()
    self.RealTimer:init()
    self.LoadTimer:init()

    self.WasReset = false
end

function LrtTimer:start()
    self:init()
    self.Running = true
    self.RealTimer:start()
    self.LoadTimer:start()
    self.LoadTimer:pause() -- Doesn't do anything, just for semantics
end

function LrtTimer:stop()
    self.Running = false
    self.RealTimer:stop()
    self.LoadTimer:stop()
end

function LrtTimer:startLoad()
    if self.Loading then
        return
    end

    self.Loading = true
    self.LoadTimer:resume() -- Doesn't do anything, just for semantics
    self.LoadStartSystemTime = GetTime({})
end

function LrtTimer:stopLoad()
    if not self.Loading then
        return
    end

    self.Loading = false
    self.LoadTimer:pause() -- Doesn't do anything, just for semantics

    local now = GetTime({})
    local timeThisLoad = now - self.LoadStartSystemTime

    self.LoadTimer:setTime(self.LoadTimer:getTime() + timeThisLoad)
    self.LoadStartSystemTime = nil
end

function LrtTimer:processLoadEvent(isLoading)
    if not self.Running then
        return
    end

    if isLoading then
        self:startLoad()
    elseif not isLoading then
        self:stopLoad()
    end
end

function LrtTimer:reset()
    self.Running = false
    self.RealTimer:reset()
    self.LoadTimer:reset()
    self.WasReset = true
end

function LrtTimer:update()
    -- LoadTimer is updated by Load Hooks, so just update the RealTimer
    self.RealTimer:update()
end

function LrtTimer:trueUp()
    self.RealTimer:trueUp()
end

function LrtTimer:getTime()
    local realTime = self.RealTimer:getTime()
    local loadTime = self.LoadTimer:getTime()

    return realTime - loadTime
end
