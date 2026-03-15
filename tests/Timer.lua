require("src/Timer/Timer")

local lu = require('luaunit')

TestTimer = {
    midrunState = {
        Running = true,
        WasReset = false,

        ElapsedTime = 250,
        Splits = {},
        StartingOffset = 0,
    },
    timer = nil,
}

function TestTimer:setUp()
    self.timer = Timer:new()
end

function TestTimer:tearDown()
    self.timer = nil
end

function TestTimer:testNewCreatesNonRunningTimer()
    lu.assertEquals(self.timer.Running, false)
end

--- Expect timer:start() to set Running to true
function TestTimer:testStart()
    self.timer:start()
    lu.assertEquals(self.timer.Running, true)
end

function TestTimer:testStop()
    self.timer:stop()
    lu.assertEquals(self.timer.Running, false)
end

function TestTimer:testReset()
    self.timer:reset()

    lu.assertEquals(self.timer.Running, false)
    lu.assertEquals(self.timer.WasReset, true)
end

function TestTimer:testUpdateDoesNothing() -- Timer should not manage its own update
    local elapsedTime = self.timer.ElapsedTime
    self.timer:update()
    lu.assertEquals(self.timer.ElapsedTime, elapsedTime)
end

os.exit(lu.LuaUnit.run())
