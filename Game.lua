local class = require "class"

local Game = class:derive("Game")

-- Place your imports here
local Vec2 = require("Vector2")
local UI = require("UI")



function Game:new()
    self.ui = UI()
end



function Game:update(dt)
    self.ui:update(dt)
end



function Game:draw()
    self.ui:draw()
	love.graphics.setColor(0, 0.2, 0.8)
	love.graphics.rectangle("fill", 0, 684, 1280, 36)
    self:drawText("level: 1, score: 200", 1000, 685, _FONTS.fontI, _COLORS.white, true)
end



function Game:splitIntoLines(text, font, maxWidth)
    local lines = {}
    for i, line in ipairs(_Utils.strSplit(text, "\n")) do
        if maxWidth then
            local pLine = ""
            for j, word in ipairs(_Utils.strSplit(line, " ")) do
                if pLine == "" then
                    if font:getWidth(word) > maxWidth then
                        error("Not implemented: too long single word for the line")
                    else
                        pLine = word
                    end
                else
                    local newPLine = pLine .. " " .. word
                    if font:getWidth(newPLine) > maxWidth then
                        -- This word won't fit in. Render it.
                        table.insert(lines, pLine)
                        pLine = word
                    else
                        pLine = newPLine
                    end
                end
            end
            if pLine ~= "" or line == "" then
                table.insert(lines, pLine)
            end
        else
            table.insert(lines, line)
        end
    end
    return lines
end



function Game:getTextSize(text, font, maxWidth, lineSquish)
    local lines = self:splitIntoLines(text, font, maxWidth)
    local size = Vec2(0, font:getHeight() * ((#lines - 1) * (1 - (lineSquish or 0)) + 1))
    for i, line in ipairs(lines) do
        size.x = math.max(size.x, font:getWidth(line))
    end
    return size
end



function Game:drawText(text, x, y, font, color, shadow, horizontalAlign, maxWidth, lineSquish)
    -- horizontalAlign (0): 0 aligns to left, 0.5 centers, 1 aligns to right
    -- maxWidth: Text will be split if it exceeds maxWidth
    -- lineSquish (0): Percent of line height to shave off from the full newline height (some fonts have chunky newlines with lots of space between them)
    horizontalAlign = horizontalAlign or 0
    lineSquish = lineSquish or 0
    local yd = math.floor(font:getHeight() * (1 - lineSquish))
    local lines = self:splitIntoLines(text, font, maxWidth)

	love.graphics.setFont(font)
    for i, line in ipairs(lines) do
        local xa = math.floor(x - font:getWidth(line) * horizontalAlign)
        if shadow then
            love.graphics.setColor(0, 0, 0)
            love.graphics.print(line, xa + 1, y + 1)
        end
        love.graphics.setColor(color[1], color[2], color[3])
        love.graphics.print(line, xa, y)
        y = y + yd
    end
end



function Game:mousepressed(x, y, button)
	self.ui:mousepressed(x, y, button)
end



function Game:mousereleased(x, y, button)
	self.ui:mousereleased(x, y, button)
end



function Game:mousemoved(x, y, dx, dy)
	self.ui:mousemoved(x, y, dx, dy)
end



function Game:keypressed(key)
    self.ui:keypressed(key)
end



return Game