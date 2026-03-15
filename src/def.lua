---@meta HadesSpeedrunning-SpeedrunTimer
local public = {
    SpeedrunTimer,
}

---@return string realTime Real time the timer has been running, formatted
function public.getRealTime() end

---@return string loadRemovedTime Time the timer has been running without loads, formatted
function public.getLoadRemovedTime() end

---@return string inGameTime In-game time for the current run -- the same as _worldTime
function public.getInGameTime() end

return public
