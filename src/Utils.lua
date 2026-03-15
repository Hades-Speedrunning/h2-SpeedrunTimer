function FormatTimestamp(timestamp)
    local minutes = 0
    local hours = 0

    local centiseconds = (timestamp % 1) * 100
    local seconds = timestamp % 60

    -- If it hasn't been over a minute, no reason to do this calculation
    if timestamp > 60 then
        minutes = math.floor((timestamp % 3600) / 60)
    end

    -- If it hasn't been over an hour, no reason to do this calculation
    if timestamp > 3600 then
        hours = math.floor(timestamp / 3600)
    end

    -- If it hasn't been over an hour, only display minutes:seconds.centiseconds
    if hours == 0 then
        return string.format("%02d:%02d.%02d", minutes, seconds, centiseconds)
    end

    return string.format("%02d:%02d:%02d.%02d", hours, minutes, seconds, centiseconds)
end

function ShouldStartTimerOnRunStart(timer)
    -- If single run, timer should always start
    -- If multiweapon, only start if timer was reset
    return not config.MultiWeapon or timer.TimerWasReset
end

--- Draw the current time on the screen
function drawTimer(timerName, timer, y_offset)
    createOverlayLine(
        "SpeedrunTimer:" .. timerName,
        FormatTimestamp(timer:getTime()),
        MergeTables(
            UIData.CurrentRunDepth.TextFormat,
            {
                justification = "left",
                x_pos = 1820,
                y_pos = 90 + y_offset,
                font_size = 20,
            }
        )
    )
end

--- Util method to draw text to the screen
-- @param obstacleName Name of textbox
-- @param text String to display
-- @param kwargs Format values (defaults to Chamber Number format)
-- font, font_size, color, outline_color, justification, shadow_color
function createOverlayLine(obstacleName, text, kwargs)
    -- Use Chamber Number as default font style
    local text_config_table = DeepCopyTable(UIData.CurrentRunDepth.TextFormat)
    -- Throw the text somewhere in the middle of the screen, if not specified
    local x_pos = 500
    local y_pos = 500

    if kwargs ~= nil then
        text_config_table.Font = kwargs.font or text_config_table.Font
        text_config_table.FontSize = kwargs.font_size or text_config_table.FontSize
        text_config_table.Color = kwargs.color or text_config_table.Color
        text_config_table.OutlineColor = kwargs.outline_color or text_config_table.OutlineColor
        text_config_table.Justification = kwargs.justification or text_config_table.Justification
        text_config_table.ShadowColor = kwargs.shadow_color or { 0, 0, 0, 0 }
        x_pos = kwargs.x_pos or 500
        y_pos = kwargs.y_pos or 500
    end

    -- If this anchor was already created, just modify the existing textbox
    if ScreenAnchors[obstacleName] ~= nil then
        ModifyTextBox({
            Id = ScreenAnchors[obstacleName],
            Text = text,
            Color = (kwargs or { color = Color.White }).color or text_config_table.Color
        })
    else -- create a new anchor/textbox and fade it in
        ScreenAnchors[obstacleName] = CreateScreenObstacle({
            Name = "BlankObstacle",
            X = x_pos,
            Y = y_pos,
            Group = "Combat_Menu_TraitTray_Overlay"
        })

        CreateTextBox(
            MergeTables(
                text_config_table,
                {
                    Id = ScreenAnchors[obstacleName],
                    Text = text
                }
            )
        )

        ModifyTextBox({
            Id = ScreenAnchors[obstacleName],
            FadeTarget = 1,
            FadeDuration = 0.0
        })
    end
end

function destroyScreenAnchor(obstacleName)
    if ScreenAnchors[obstacleName] ~= nil then
        Destroy({ Id = ScreenAnchors[obstacleName] })
        ScreenAnchors[obstacleName] = nil
    end
end
