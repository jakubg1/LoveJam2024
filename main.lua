local font = love.graphics.newFont("fonts/Lambda-Regular.ttf", 18)
local fontBig = love.graphics.newFont("fonts/Lambda-Regular.ttf", 24)
local fontI = love.graphics.newFont("fonts/Lambda-Italic.ttf", 28)

function love.update(dt)
end

function love.draw()
	love.graphics.setColor(0, 0.2, 0.8)
	love.graphics.rectangle("fill", 0, 684, 1280, 36)
	love.graphics.setFont(fontI)
	love.graphics.setColor(0, 0, 0)
	love.graphics.print("level: 1, score: 200", 1003, 686)
	love.graphics.setColor(1, 1, 1)
	love.graphics.print("level: 1, score: 200", 1000, 685)
end
