-- scripts/lib/TranZlator/welcomegraphic.lua

-- Function to draw a solid background
local function draw_background(x, y, width, height, color)
    directx.draw_rect(x, y, width, height, color)
end

-- Function to display a welcome graphic
function display_welcome_graphic()
    local display_duration = 3000  -- Display for 3 seconds
    local start_time = util.current_time_millis()

    while util.current_time_millis() - start_time < display_duration do
        -- Calculate pulsating alpha value
        local alpha = 0.5 + 0.5 * math.sin((util.current_time_millis() - start_time) / 200)
        local backgroundColor = {r = 0.0, g = 0.0, b = 0.0, a = alpha}

        -- Draw solid background rectangle
        draw_background(0.435, 0.46, 0.13, 0.1, backgroundColor)

        -- Draw welcome text
        directx.draw_text(0.5, 0.49, "TranZlator", 5, 1.2, {r = 1.0, g = 1.0, b = 1.0, a = 1.0}, true)
        directx.draw_text(0.5, 0.515, "Version " .. verNum, 5, 0.8, {r = 0, g = 1.0, b = 0, a = 1.0}, true)
        directx.draw_text(0.5, 0.54, "Created by Cracky", 5, 0.6, {r = 1.0, g = 1.0, b = 1.0, a = 1.0}, true)

        util.yield()
    end
end
