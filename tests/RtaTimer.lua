require("src/Timer/RtaTimer")
require("tests/TestUtils")

local lu = require('luaunit')

TestRtaTimer = {
    timer = nil,
    clock = nil,
}

function TestRtaTimer:setUp()
    self.clock = UseFakeTime({ currentTime = 0 })
    self.timer = RtaTimer:new()
end

function TestRtaTimer:tearDown()
    RestoreRealTime()
    self.timer = nil
    self.clock = nil
end

function TestRtaTimer:testNewCreatesNonRunningTimer()
    lu.assertEquals(self.timer.Running, false)
end

--- Expect timer:start() to set Running to true
function TestRtaTimer:testStart()
    self.timer:start()
    lu.assertEquals(self.timer.Running, true)
    lu.assertEquals(self.timer.PreviousWorldTime, _worldTime)
end

--- Expect timer:stop to set Running to false
function TestRtaTimer:testStopSetsRunningToFalse()
    self.timer:start()
    self.timer:stop()
    lu.assertEquals(self.timer.Running, false)
end

function TestRtaTimer:testResetResetsTimer()
    self.timer:start()
    self.timer:reset()

    lu.assertEquals(self.timer.Running, false)
    lu.assertEquals(self.timer.WasReset, true)
    lu.assertEquals(self.timer.Cycle, nil)
    lu.assertEquals(self.timer.PreviousWorldTime, nil)
end

function TestRtaTimer:testProcessWorldTime()
    local timeToElapse = 20

    self.timer:start()
    local startingTime = self.timer.ElapsedTime

    self.clock:advanceTime(timeToElapse)
    self.timer:processWorldTime()

    lu.assertEquals(self.timer.ElapsedTime, startingTime + timeToElapse)
    lu.assertEquals(self.timer.PreviousWorldTime, _worldTime)
end

function TestRtaTimer:testUpdate()
    local timeToElapse = 10

    self.timer:start()
    local startingTime = self.timer.ElapsedTime

    self.clock:advanceTime(timeToElapse)
    self.timer:update()


    lu.assertEquals(self.timer.ElapsedTime, startingTime + timeToElapse)
    lu.assertEquals(self.timer.Cycle, 1)
end

function TestRtaTimer:testTrueUp()
    local timeToElapse = 15

    self.timer:start()
    local startingTime = self.timer.ElapsedTime

    self.clock:advanceTime(timeToElapse, true)
    self.timer:processWorldTime()

    lu.assertEquals(self.timer.ElapsedTime, startingTime)

    self.timer:trueUp()

    lu.assertEquals(self.timer.ElapsedTime, startingTime + timeToElapse)
end

os.exit(lu.LuaUnit.run())
