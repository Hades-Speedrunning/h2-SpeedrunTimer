require("src/Timer/LrtTimer")
require("tests/TestUtils")

local lu = require('luaunit')

TestLrtTimer = {
    timer = nil,
    clock = nil,
}

function TestLrtTimer:setUp()
    self.clock = UseFakeTime({ currentTime = 0 })
    self.timer = LrtTimer:new()
end

function TestLrtTimer:tearDown()
    self.timer = nil
    self.clock = nil
    RestoreRealTime()
end

function TestLrtTimer:testNewCreatesNonRunningTimer()
    lu.assertEquals(self.timer.Running, false)
end

--- Expect timer:start() to set Running to true
function TestLrtTimer:testStart()
    self.timer:start()
    lu.assertEquals(self.timer.Running, true)
    lu.assertEquals(self.timer.TimeElapsedThisLoad, _worldTime)
end

--- Expect timer:stop to set Running to false
function TestLrtTimer:testStopSetsRunningToFalse()
    self.timer.LoadTimer:start()
    self.timer.LoadTimer:stop()
    lu.assertEquals(self.timer.Running, false)
end

function TestLrtTimer:testResetResetsTimer()
    self.timer:start()
    self.timer:reset()

    lu.assertEquals(self.timer.Running, false)
    lu.assertEquals(self.timer.WasReset, true)
    lu.assertEquals(self.timer.Cycle, nil)
    lu.assertEquals(self.timer.PreviousWorldTime, nil)
end

function TestLrtTimer:testUpdate()
    local timeToElapse = 10

    self.timer:start()
    local startingTime = self.timer:getTime()

    self.clock:advanceTime(timeToElapse)
    self.timer:update()

    lu.assertEquals(self.timer:getTime(), startingTime + timeToElapse)
end

function TestLrtTimer:testTrueUp()
    local timeToElapse = 15

    self.timer:start()
    local startingTime = self.timer:getTime()

    self.clock:advanceTime(timeToElapse, true)
    self.timer:update()

    lu.assertEquals(self.timer:getTime(), startingTime)

    self.timer:trueUp()

    lu.assertEquals(self.timer:getTime(), startingTime + timeToElapse)
end

function TestLrtTimer:testHandlesLoad()
    local timeToElapse = 10

    self.timer:start()
    local startingTime = self.timer:getTime()

    self.clock:advanceTime(timeToElapse)
    self.timer:update()

    self.timer:startLoad()
    self.clock:advanceTime(timeToElapse)
    self.timer:update()

    self.timer:stopLoad()
    self.clock:advanceTime(timeToElapse)
    self.timer:update()

    lu.assertEquals(self.timer:getTime(), startingTime + 2 * timeToElapse)
end

os.exit(lu.LuaUnit.run())
