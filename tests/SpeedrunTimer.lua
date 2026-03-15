require('src/Timer/SpeedrunTimer')
require("tests/TestUtils")


local lu = require('luaunit')

TestSpeedrunTimer = {
    timer = nil,
    clock = nil,
    loadListener = nil,
}

function TestSpeedrunTimer:setUp()
    self.clock = UseFakeTime({ currentTime = 0 })
    self.loadListener = MockLoadListener:new()
    self.timer = SpeedrunTimer:new()
    self.loadListener:addLoadHook(self.timer:getLoadHook())
end

function TestSpeedrunTimer:tearDown()
    self.timer = nil
    self.clock = nil
    RestoreRealTime()
end

function TestSpeedrunTimer:testHandlesTwoChambers()
    self.timer:start()
    self.clock:advanceTime(100)
    self.timer:update()

    lu.assertEquals(self.timer:getRealTime(), 100)
    lu.assertEquals(self.timer:getLoadRemovedTime(), 100)

    self.clock:advanceTime(100)
    self.timer:update()

    lu.assertEquals(self.timer:getRealTime(), 200)
    lu.assertEquals(self.timer:getLoadRemovedTime(), 200)

    self.loadListener:startLoad()

    self.clock:advanceTime(50)
    self.timer:update()

    lu.assertEquals(self.timer:getRealTime(), 250)
    lu.assertEquals(self.timer:getLoadRemovedTime(), 200)

    self.loadListener:endLoad()

    self.clock:advanceTime(50)
    self.timer:update()

    lu.assertEquals(self.timer:getRealTime(), 300)
    lu.assertEquals(self.timer:getLoadRemovedTime(), 250)
end

function TestSpeedrunTimer:testNonLoadingUpdateIsIdempotent()
    self.timer:start()
    self.clock:advanceTime(100)
    self.timer:update()
    self.timer:update()
    self.timer:update()

    lu.assertEquals(self.timer:getRealTime(), 100)
    lu.assertEquals(self.timer:getLoadRemovedTime(), 100)
end

function TestSpeedrunTimer:testLoadingUpdateIsIdempotent()
    self.timer:start()
    self.clock:advanceTime(100)
    self.loadListener:startLoad()
    self.clock:advanceTime(50)

    self.timer:update()
    self.timer:update()
    self.timer:update()

    lu.assertEquals(self.timer:getRealTime(), 150)
    lu.assertEquals(self.timer:getLoadRemovedTime(), 100)
end

os.exit(lu.LuaUnit.run())
