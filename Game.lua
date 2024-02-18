local class = require "class"

local Game = class:derive("Game")

-- Place your imports here
local UI = require("UI")



function Game:new()
    self.ui = UI()
end



function Game:update(dt)
    self.ui:update(dt)
end



function Game:draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(_IMAGES.desktop)
    self.ui:draw()
	love.graphics.setColor(0, 0.2, 0.8)
	love.graphics.rectangle("fill", 0, 684, 1280, 36)
    self:drawText("level: 1, score: 200", 1000, 685, _FONTS.fontI, _COLORS.white, true)
end



function Game:drawText(text, x, y, font, color, shadow)
	love.graphics.setFont(font)
    if shadow then
    	love.graphics.setColor(0, 0, 0)
	    love.graphics.print(text, x + 1, y + 1)
    end
	love.graphics.setColor(color[1], color[2], color[3])
	love.graphics.print(text, x, y)
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