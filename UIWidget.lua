local class = require "class"

local UIWidget = class:derive("UIWidget")

-- Place your imports here



function UIWidget:new(data)
    self.parent = nil
    self.children = {}

    -- For everything (some still optional)
    self.name = data.name
    self.type = data.type
    self.pos = data.pos
    self.size = data.size
    self.align = data.align
    self.parentAlign = data.parentAlign

    -- Images only
    self.image = data.image

    -- Sprites only
    self.sprite = data.sprite
    self.draggable = data.draggable
    self.dragMaxY = data.dragMaxY

    -- Text only
    self.text = data.text
    self.font = data.font
    self.color = data.color
    self.shadow = data.shadow

    -- State
    self.isBeingDragged = false

    -- Cache (set to nil to regenerate the value the next time it's needed)
    self.globalPos = nil
    self.globalSize = nil
end



function UIWidget:addChild(child)
    table.insert(self.children, child)
    child.parent = self
end



function UIWidget:getGlobalPos()
    if self.globalPos then
        return self.globalPos
    end
    -- No cache available, (re)generate.
    if self.parent then
        local p = self.parent:getGlobalPos()
        local x = p.x + self.pos.x
        local y = p.y + self.pos.y
        if self.align then
            local s = self:getGlobalSize()
            x = x - math.floor(s.x * self.align.x)
            y = y - math.floor(s.y * self.align.y)
        end
        if self.parentAlign then
            local s = self.parent:getGlobalSize()
            x = x + math.floor(s.x * self.parentAlign.x)
            y = y + math.floor(s.y * self.parentAlign.y)
        end
        self.globalPos = {x = x, y = y}
    else
        self.globalPos = self.pos
    end
    return self.globalPos
end



function UIWidget:getGlobalSize()
    if self.globalSize then
        return self.globalSize
    end
    -- No cache available, (re)generate.
    if self.size then
        self.globalSize = self.size
    elseif self.type == "image" then
        self.globalSize = {x = self.image:getWidth(), y = self.image:getHeight()}
    elseif self.type == "text" then
        self.globalSize = {x = self.font:getWidth(self.text), y = self.font:getHeight() * #_Utils.strSplit(self.text, "\n")}
    else
        self.globalSize = self.parent:getGlobalSize()
    end
    return self.globalSize
end



function UIWidget:refreshGlobalPos()
    self.globalPos = nil
    for i, child in ipairs(self.children) do
        child:refreshGlobalPos()
    end
end



function UIWidget:setPos(pos)
    self.pos = pos
    self:refreshGlobalPos()
end



function UIWidget:isHovered()
    local p = self:getGlobalPos()
    local s = self:getGlobalSize()
    return _MouseX >= p.x and _MouseY >= p.y and _MouseX <= p.x + s.x and _MouseY <= p.y + s.y
end



function UIWidget:draw()
    local p = self:getGlobalPos()

    love.graphics.setColor(1, 1, 1)
    if self.type == "image" then
        love.graphics.draw(self.image, p.x, p.y)
    elseif self.type == "sprite" then
        self.sprite:draw(p.x, p.y, self.size.x, self.size.y)
    elseif self.type == "text" then
        _Game:drawText(self.text, p.x, p.y, self.font, self.color, self.shadow)
    end

    if self.children then
        for i, child in ipairs(self.children) do
            child:draw()
        end
    end
end



function UIWidget:drawDebug()
    local p = self:getGlobalPos()
    local s = self:getGlobalSize()

    love.graphics.setColor(1, 0, 0, 0.5)
    love.graphics.rectangle("fill", p.x, p.y, s.x, s.y)
end



function UIWidget:mousepressed(x, y, button)
    if self.draggable and button == 1 and self:isHovered() and (not self.dragMaxY or y - self:getGlobalPos().y <= self.dragMaxY) then
        self.isBeingDragged = true
    end
end



function UIWidget:mousereleased(x, y, button)
    if self.isBeingDragged and button == 1 then
        self.isBeingDragged = false
    end
end



function UIWidget:mousemoved(x, y, dx, dy)
    if self.isBeingDragged then
        self:setPos({x = self.pos.x + dx, y = self.pos.y + dy})
    end
end



return UIWidget