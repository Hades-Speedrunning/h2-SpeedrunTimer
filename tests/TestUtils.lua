RealTimers = {
    GetTime = nil,
    _worldTime = nil,
    wait = nil,
}

FakeTimer = {
    currentTime = 0,
    _worldTime = 0,
    wait = nil,
}

function FakeTimer:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    return o
end

function FakeTimer:advanceTime(milliseconds, gamePaused)
    if self.currentTime == nil then
        error("Timer not initialized. Use setTime() to initialize the timer.")
    end

    self.currentTime = self.currentTime + milliseconds

    if not gamePaused then
        _worldTime = self.currentTime
    end
end

function FakeTimer:getTime()
    if self.currentTime == nil then
        return 0
    end

    return self.currentTime
end

function FakeTimer:setTime(seconds)
    self.currentTime = seconds
end

UseFakeTime = function(options)
    RealTimers.GetTime = GetTime

    local clock = FakeTimer:new(options)
    GetTime = function()
        return clock:getTime()
    end

    _worldTime = clock.currentTime
    RealTimers.wait = wait

    wait = function(seconds)
        clock:advanceTime(seconds * 1000)
    end

    return clock
end

RestoreRealTime = function()
    GetTime = RealTimers.GetTime
    _worldTime = RealTimers._worldTime
    wait = RealTimers.wait
end


MockLoadListener = {
    onLoad = {},
}

function MockLoadListener:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    return o
end

function MockLoadListener:addLoadHook(hook)
    table.insert(self.onLoad, hook)
end

function MockLoadListener:startLoad()
    for _, func in ipairs(self.onLoad) do
        func(true)
    end
end

function MockLoadListener:endLoad()
    for _, func in ipairs(self.onLoad) do
        func(false)
    end
end
