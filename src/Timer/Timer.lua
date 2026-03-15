--- Definition of a Timer that only provides the most basic functionality.
--- This includes basic controls such as start, stop, and reset. It also
--- includes providing a formatted output of the current ElapsedTime.
--- However, it DOES NOT include an implementation of the update function.
--- Its subclasses are expected to implement that based on what they are timing.

Timer = {
    -- Running: boolean,
    -- WasReset: boolean,

    -- ElapsedTime: number,
    -- Splits: table,
}


function Timer:new(args)
    args = args or {}

    local o = {
        Running = args.Running or false,
        WasReset = args.WasReset or false,

        ElapsedTime = args.ElapsedTime or 0,
        Splits = args.Splits or {},
    }

    setmetatable(o, self)
    self.__index = self
    return o
end

function Timer:init(startingOffset)
    self.ElapsedTime = startingOffset or 0
end

--- Start the timer.
-- @param startingOffset The time to start the timer from. If nil, it will start at 0.
function Timer:start(startingOffset)
    self:init(startingOffset)
    self.Running = true
    self.Paused = false
end

--- Set the starting offset for the timer, which is the time that the timer will start from.
-- @param time The time to start the timer from. If nil, it will start at 0.
function Timer:setTime(time)
    self.ElapsedTime = time
end

--- Get the current elapsed time of the timer.
-- @return The current elapsed time.
function Timer:getTime()
    return self.ElapsedTime
end

function Timer:pause()
    self.Paused = true
    self:trueUp()
end

function Timer:resume()
    self.Paused = false
end
--- Stop the timer, and immediately true up.
function Timer:stop()
    self.Running = false
    self:trueUp()
end

function Timer:reset()
    self.Running = false
    self.WasReset = true
    self.StartTime = nil

    self.Cycle = nil
    self.PreviousWorldTime = nil

    self.ElapsedTime = nil
end

--- Update the timer's ElapsedTime. This is called every frame.
-- It is expected that subclasses will implement this function.
function Timer:update()
end

--- AS ACCURATELY AS POSSIBLE, update the timer's ElapsedTime to reflect
--- the state of the world. This may be expensive, so it should only be called
--- during the stop action or on a less frequent basis than every update cycle.
--- For example, an RtaTimer may rely on changes in WorldTime to estimate the
--- progression of Real Time, and only call this function once every 5 seconds
--- while WorldTime is progressing as expected. If WorldTime is paused, it may
--- call it twice a second until it is unpaused.
--- It is expected that subclasses will implement this function.
function Timer:trueUp()
end

return Timer
