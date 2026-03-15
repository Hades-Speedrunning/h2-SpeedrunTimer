--- IgtTimer is just a very light wrapper for the in-game timer that already exists
-- It allows us to define our own API and hook into it via the SpeedrunTimer
IgtTimer = {
    -- timer: SGGTimer,
}

function IgtTimer:new(timer)
    local o = {}

    setmetatable(o, self)
    self.__index = self
    return o
end

--- Set the current time for the timer, which is the time that the timer will start from.
-- @param time The time to start the timer from. If nil, it will start at 0.
function IgtTimer:getTime()
    return _worldTime
end

return IgtTimer
