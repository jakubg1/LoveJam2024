local Game = require("Game")
local NineSprite = require("NineSprite")

_Utils = require("utils")

_COLORS = {
	white = {1, 1, 1},
	black = {0, 0, 0}
}
_IMAGES = {
	desktop = love.graphics.newImage("images/desktop.png"),
	window = love.graphics.newImage("images/window.png"),
	button = love.graphics.newImage("images/button.png"),
	close = love.graphics.newImage("images/close.png"),
	minimize = love.graphics.newImage("images/minimize.png")
}
_SPRITES = {
	window = NineSprite(_IMAGES.window, 5, 95, 33, 95),
	button = NineSprite(_IMAGES.button, 4, 44, 4, 12)
}
_FONTS = {
	windowHeader = love.graphics.newFont("fonts/Lambda-Regular.ttf", 24),
	windowContents = love.graphics.newFont("fonts/EnterCommand.ttf", 24),
	fontI = love.graphics.newFont("fonts/Lambda-Italic.ttf", 28)
}

_Game = nil

_MouseX = 0
_MouseY = 0



function love.load()
	_Game = Game()
end



function love.update(dt)
	_MouseX = love.mouse.getX()
	_MouseY = love.mouse.getY()
	_Game:update(dt)
end



function love.draw()
	_Game:draw()
end



function love.mousepressed(x, y, button)
	_Game:mousepressed(x, y, button)
end



function love.mousereleased(x, y, button)
	_Game:mousereleased(x, y, button)
end



function love.mousemoved(x, y, dx, dy)
	_Game:mousemoved(x, y, dx, dy)
end



function love.keypressed(key)
	_Game:keypressed(key)
end