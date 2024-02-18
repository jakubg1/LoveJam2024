local class = require "class"

local NineSprite = class:derive("NineSprite")

-- Place your imports here



function NineSprite:new(image, x1, x2, y1, y2)
    self.image = image
    self.x1 = x1
    self.x2 = x2
    self.y1 = y1
    self.y2 = y2

    -- Size of center piece
    self.cx = x2 - x1
    self.cy = y2 - y1
    -- Size of bottom right piece
    self.brx = image:getWidth() - x2
    self.bry = image:getHeight() - y2

    self.pieces = {
		top_left = love.graphics.newQuad(0, 0, x1, y1, image),
		top = love.graphics.newQuad(x1, 0, self.cx, y1, image),
		top_right = love.graphics.newQuad(x2, 0, self.brx, y1, image),
		left = love.graphics.newQuad(0, y1, x1, self.cy, image),
		center = love.graphics.newQuad(x1, y1, self.cx, self.cy, image),
		right = love.graphics.newQuad(x2, y1, self.brx, self.cy, image),
		bottom_left = love.graphics.newQuad(0, y2, x1, self.bry, image),
		bottom = love.graphics.newQuad(x1, y2, self.cx, self.bry, image),
		bottom_right = love.graphics.newQuad(x2, y2, self.brx, self.bry, image)
    }
end



function NineSprite:draw(x, y, w, h)
    local x1 = x + self.x1
    local x2 = x + w - self.brx
    local y1 = y + self.y1
    local y2 = y + h - self.bry
    local centerStretchFactorX = (w - self.x1 - self.brx) / self.cx
    local centerStretchFactorY = (h - self.y1 - self.bry) / self.cy
    love.graphics.draw(self.image, self.pieces.top_left, x, y)
    love.graphics.draw(self.image, self.pieces.top, x1, y, 0, centerStretchFactorX, 1)
    love.graphics.draw(self.image, self.pieces.top_right, x2, y)
    love.graphics.draw(self.image, self.pieces.left, x, y1, 0, 1, centerStretchFactorY)
    love.graphics.draw(self.image, self.pieces.center, x1, y1, 0, centerStretchFactorX, centerStretchFactorY)
    love.graphics.draw(self.image, self.pieces.right, x2, y1, 0, 1, centerStretchFactorY)
    love.graphics.draw(self.image, self.pieces.bottom_left, x, y2)
    love.graphics.draw(self.image, self.pieces.bottom, x1, y2, 0, centerStretchFactorX, 1)
    love.graphics.draw(self.image, self.pieces.bottom_right, x2, y2)
end



return NineSprite