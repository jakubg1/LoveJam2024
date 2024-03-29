local Vec2 = require("Vector2")
local Game = require("Game")
local NineSprite = require("NineSprite")

_Utils = require("utils")

_COLORS = {
	white = {1, 1, 1},
	gray = {0.5, 0.5, 0.5},
	lightGray = {0.8, 0.8, 0.8},
	black = {0, 0, 0},
	red = {1, 0, 0}
}
_IMAGES = {
	desktop = love.graphics.newImage("images/desktop.png"),
	window = love.graphics.newImage("images/window.png"),
	windowDisabled = love.graphics.newImage("images/window_disabled.png"),
	button = love.graphics.newImage("images/button.png"),
	buttonPressed = love.graphics.newImage("images/button_pressed.png"),
	close = love.graphics.newImage("images/close.png"),
	closePressed = love.graphics.newImage("images/close_pressed.png"),
	closeDisabled = love.graphics.newImage("images/close_disabled.png"),
	minimize = love.graphics.newImage("images/minimize.png"),
	minimizePressed = love.graphics.newImage("images/minimize_pressed.png"),
	minimizeDisabled = love.graphics.newImage("images/minimize_disabled.png")
}
_SPRITES = {
	window = NineSprite(_IMAGES.window, 5, 95, 33, 95),
	windowDisabled = NineSprite(_IMAGES.windowDisabled, 5, 95, 33, 95),
	button = NineSprite(_IMAGES.button, 4, 44, 4, 12),
	buttonPressed = NineSprite(_IMAGES.buttonPressed, 4, 44, 4, 12)
}
_FONTS = {
	windowHeader = love.graphics.newFont("fonts/Lambda-Regular.ttf", 24),
	windowContents = love.graphics.newFont("fonts/EnterCommand.ttf", 24),
	windowContentsBold = love.graphics.newFont("fonts/EnterCommand-Bold.ttf", 24),
	fontI = love.graphics.newFont("fonts/Lambda-Italic.ttf", 28)
}

_Game = nil

_MousePos = Vec2()



function love.load()
	_Game = Game()
end



function love.update(dt)
	_MousePos = Vec2(love.mouse.getPosition())
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