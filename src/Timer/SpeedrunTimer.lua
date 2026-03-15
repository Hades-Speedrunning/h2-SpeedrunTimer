import 'Timer/RtaTimer.lua'
import 'Timer/LrtTimer.lua'
import 'Timer/IgtTimer.lua'
import 'Utils.lua'

SpeedrunTimer = {
    -- RtaTimer: RtaTimer
    -- LrtTimer: LrtTimer
    -- IgtTimer: Timer
}

function SpeedrunTimer:new(args)
    args = args or {}

    local o = {}
    o.RtaTimer = RtaTimer:new()
    o.LrtTimer = LrtTimer:new({ withRtaTimer = o.RtaTimer })
    o.IgtTimer = IgtTimer:new()

    setmetatable(o, self)
    self.__index = self
    return o
end

function SpeedrunTimer:getInGameTime()
    return self.IgtTimer:getTime()
end

function SpeedrunTimer:getRealTime()
    return self.RtaTimer:getTime()
end

function SpeedrunTimer:getLoadRemovedTime()
    return self.LrtTimer:getTime()
end

function SpeedrunTimer:getLoadHook()
    local handleLoadClosure = function(isLoading)
        self.LrtTimer:processLoadEvent(isLoading)
    end
    return handleLoadClosure
end

function SpeedrunTimer:addRunHooks()
    modutil.mod.Path.Wrap("RoomEntranceMaterialize", function(baseFunc, ...)
        local val = baseFunc(...)

        if ShouldStartTimerOnRunStart(self) then
            self:start()
        end

        thread(mod.SpeedrunTimer:getUpdateThread())

        return val
    end, SpeedrunTimer)


    -- Stop timer when Chronos dies (but leave it on screen)
    modutil.mod.Path.Wrap("ChronosKillPresentation", function(baseFunc, ...)
        self:stop()
        baseFunc(...)
    end, SpeedrunTimer)
end

function SpeedrunTimer:addLoadHooks()
    modutil.mod.Path.Wrap("AddTimerBlock", function(baseFunc, _currRun, timerBlockName)
        local val = baseFunc(_currRun, timerBlockName)

        if timerBlockName == "MapLoad" and self.LrtTimer ~= nil and self.LrtTimer.Running then
            self.LrtTimer:processLoadEvent(true)
        end

        return val
    end, SpeedrunTimer)

    modutil.mod.Path.Wrap("RemoveTimerBlock", function(baseFunc, _currRun, timerBlockName)
        local val = baseFunc(_currRun, timerBlockName)

        if timerBlockName == "MapLoad" and self.LrtTimer ~= nil and self.LrtTimer.Running then
            self.LrtTimer:processLoadEvent(false)
        end

        return val
    end, SpeedrunTimer)
end
function SpeedrunTimer:start()
    self.Running = true
    self.RtaTimer:start()
    self.LrtTimer:start()
end

function SpeedrunTimer:reset()
    self.Running = false

    self.RtaTimer:reset()
    self.LrtTimer:reset()
end

function SpeedrunTimer:stop()
    self.Running = false

    self.RtaTimer:stop()
    self.LrtTimer:stop()
end
function SpeedrunTimer:getUpdateThread()
    local updateThreadClosure = function()
        while self.Running do
            self:update()
            -- Update once per frame
            wait(0.016, "SpeedrunTimer", true)
        end
    end

    return updateThreadClosure
end

function SpeedrunTimer:update()
    self.RtaTimer:update()
    self.LrtTimer:update()
    drawTimer('LrtTimer', self.LrtTimer, 30)
    drawTimer('RtaTimer', self.RtaTimer, 50)
end
