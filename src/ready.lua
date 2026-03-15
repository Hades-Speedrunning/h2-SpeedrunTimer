---@meta _
---@diagnostic disable: lowercase-global

import 'Timer/SpeedrunTimer.lua'

mod = modutil.mod.Mod.Register(_PLUGIN.guid)
plugin_path = _PLUGIN.plugins_mod_folder_path or 'src/'

mod.SpeedrunTimer = SpeedrunTimer:new()
mod.SpeedrunTimer:addRunHooks()
mod.SpeedrunTimer:addLoadHooks()

function mod.getRealTime()
    local realTime = mod.SpeedrunTimer.getRealTime()
    return FormatTimestamp(realTime)
end

function mod.getLoadRemovedTime()
    local loadRemovedTime = mod.SpeedrunTimer.getLoadRemovedTime()
    return FormatTimestamp(loadRemovedTime)
end

function mod.getInGameTime()
    local inGameTime = mod.SpeedrunTimer.getInGameTime()
    return FormatTimestamp(inGameTime)
end

modutil.mod.LoadOnce(
    function()
        -- If not in a run, reset timer and prepare for run start
        if CurrentRun.Hero.IsDead then
            mod.SpeedrunTimer:reset()
            -- If in a run, just start the timer from the time the mod was loaded
        else
            mod.SpeedrunTimer:start()
            thread(mod.SpeedrunTimer:getUpdateThread())
        end
    end
)
