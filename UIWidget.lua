local class = require "class"

local UIWidget = class:derive("UIWidget")

-- Place your imports here
local Vec2 = require("Vector2")



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
    self.imagePressed = data.imagePressed
    self.imageUnfocused = data.imageUnfocused

    -- Sprites only
    self.sprite = data.sprite
    self.spritePressed = data.spritePressed
    self.spriteUnfocused = data.spriteUnfocused
    self.draggable = data.draggable
    self.dragMaxY = data.dragMaxY
    self.focusMovesToFront = data.focusMovesToFront

    -- Text only
    self.text = data.text
    self.font = data.font
    self.color = data.color
    self.colorUnfocused = data.colorUnfocused
    self.shadow = data.shadow
    self.lineWidth = data.lineWidth
    self.lineSquish = data.lineSquish

    -- Callbacks
    self.onPressed = data.onPressed

    -- State
    self.focused = false
    self.pressed = false
    self.isBeingDragged = false
    self.dragOffset = nil

    -- Cache (set to nil to regenerate the value the next time it's needed)
    self.globalPos = nil
    self.globalSize = nil
end



function UIWidget:getChild(name)
    for i, child in ipairs(self.children) do
        if child.name == name then
            return child
        end
    end
    return nil
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
        local pp = self.parent:getGlobalPos()
        local p = pp:clone()
        if self.pos then
            p = p + self.pos
        end
        if self.align then
            local s = self:getGlobalSize()
            p = p - (s * self.align):floor()
        end
        if self.parentAlign then
            local s = self.parent:getGlobalSize()
            p = p + (s * self.parentAlign):floor()
        end
        self.globalPos = p
    else
        self.globalPos = self.pos or Vec2()
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
        self.globalSize = Vec2(self.image:getWidth(), self.image:getHeight())
    elseif self.type == "text" then
        self.globalSize = _Game:getTextSize(self.text, self.font, self.lineWidth, self.lineSquish)
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



function UIWidget:setFocus(focus)
    self.focused = focus
    if focus and self.focusMovesToFront and self.parent then
        self:moveToFront()
    end
    for i, child in ipairs(self.children) do
        child:setFocus(focus)
    end
end



function UIWidget:moveToFront()
    assert(self.parent, "Why would you want to move a root node to the front? (or perhaps a node that isn't attached to the tree?)")
    _Utils.removeValueFromList(self.parent.children, self)
    table.insert(self.parent.children, self)
    _Game.ui:generateDebugWidgetTree()
end



function UIWidget:close()
    _Utils.removeValueFromList(self.parent.children, self)
    _Game.ui:generateDebugWidgetTree()
end



function UIWidget:isHovered()
    return _Utils.isPointInsideBox(_MousePos, self:getGlobalPos(), self:getGlobalSize())
end



function UIWidget:getFrontmostHoveredChild()
    -- We're starting from the last child, as that's the last child to be drawn = is on the front.
    for i = #self.children, 1, -1 do
        if self.children[i]:isHovered() then
            return self.children[i]
        end
    end
    return nil
end



function UIWidget:findIndirectParentThatIsAChildOf(widget)
    -- For example, if we're a button, and we pass the whole desktop, what we'll get is the window which hosts that button.
    local w = self
    while w and w.parent ~= widget do
        w = w.parent
    end
    return w
end



function UIWidget:draw()
    local p = self:getGlobalPos()

    love.graphics.setColor(1, 1, 1)
    if self.type == "image" then
        local image = self.image
        -- Replace the image with a pressed version if it exists.
        if self.pressed and self:isHovered() then
            image = self.imagePressed or image
        elseif not self.focused then
            image = self.imageUnfocused or image
        end
        love.graphics.draw(image, p.x, p.y)
    elseif self.type == "sprite" then
        local sprite = self.sprite
        -- Replace the sprite with a pressed version if it exists.
        if self.pressed and self:isHovered() then
            sprite = self.spritePressed or sprite
        elseif not self.focused then
            sprite = self.spriteUnfocused or sprite
        end
        sprite:draw(p.x, p.y, self.size.x, self.size.y)
    elseif self.type == "text" then
        local color = self.color
        if not self.focused then
            color = self.colorUnfocused or color
        end
        local horizontalAlign = 0
        if self.align then
            horizontalAlign = self.align.x
        end
        local s = self:getGlobalSize()
        _Game:drawText(self.text, p.x + horizontalAlign * s.x, p.y, self.font, color, self.shadow, horizontalAlign, self.lineWidth, self.lineSquish)
    end

    for i, child in ipairs(self.children) do
        child:draw()
    end
end



function UIWidget:getDebugText()
    return string.format("%s (%s)", self.name or "<unnamed>", self.type or "none")
end



function UIWidget:drawDebug()
    -- Explanation of debug controls:
    -- This Widget's box (pos and size) is marked in orange.
    -- The alignment pivot will be marked as an red plus.
    -- The darker outline colors pixels which are JUST OUTSIDE of its box!
    -- If this Widget has a parent-relative alignment set (self.parentAlign):
    --   - the parent's box will be drawn in aqua,
    --   - the parent-relative pivot will be marked as a blue plus.

    -- Draw parent's alignment helpers if applicable.
    if self.parentAlign then
        -- Draw parent's box.
        local pp = self.parent:getGlobalPos()
        local ps = self.parent:getGlobalSize()
        love.graphics.setColor(0, 1, 1, 0.25)
        love.graphics.rectangle("fill", pp.x, pp.y, ps.x, ps.y)
        love.graphics.setColor(0, 1, 1, 0.5)
        love.graphics.rectangle("line", pp.x - 0.5, pp.y - 0.5, ps.x + 1, ps.y + 1)
        -- Draw parent-relative pivot point.
        local x = pp.x + math.floor(ps.x * self.parentAlign.x)
        local y = pp.y + math.floor(ps.y * self.parentAlign.y)
        love.graphics.setColor(0, 0, 1)
        love.graphics.line(x + 0.5, y - 4.5, x + 0.5, y + 5.5)
        love.graphics.line(x - 4.5, y + 0.5, x + 5.5, y + 0.5)
    elseif self.parent then
        -- Draw parent-relative pivot point.
        local pp = self.parent:getGlobalPos()
        love.graphics.setColor(0, 0, 1)
        love.graphics.line(pp.x + 0.5, pp.y - 4.5, pp.x + 0.5, pp.y + 5.5)
        love.graphics.line(pp.x - 4.5, pp.y + 0.5, pp.x + 5.5, pp.y + 0.5)
    end

    -- Draw this box.
    local p = self:getGlobalPos()
    local s = self:getGlobalSize()

    love.graphics.setColor(1, 0.5, 0, 0.5)
    love.graphics.rectangle("fill", p.x, p.y, s.x, s.y)
    love.graphics.setColor(1, 0.5, 0)
    love.graphics.rectangle("line", p.x - 0.5, p.y - 0.5, s.x + 1, s.y + 1)

    -- Draw align pivot.
    local ap = p
    if self.align then
        ap = ap + (s * self.align):floor()
    end
    love.graphics.setColor(1, 0, 0)
    love.graphics.line(ap.x + 0.5, ap.y - 4.5, ap.x + 0.5, ap.y + 5.5)
    love.graphics.line(ap.x - 4.5, ap.y + 0.5, ap.x + 5.5, ap.y + 0.5)
end



function UIWidget:mousepressed(x, y, button)
    if button == 1 and self:isHovered() then
        self.pressed = true
        if self.draggable and (not self.dragMaxY or y - self:getGlobalPos().y <= self.dragMaxY) then
            self.isBeingDragged = true
            self.dragOffset = _MousePos - self.pos
        end
    end

    for i, child in ipairs(self.children) do
        child:setFocus(false)
    end
    local widget = self:getFrontmostHoveredChild()
    if widget then
        widget:mousepressed(x, y, button)
        widget:setFocus(true)
    end
end



function UIWidget:mousereleased(x, y, button)
    if button == 1 then
        if self.pressed then
            self.pressed = false
            if self.onPressed and self:isHovered() then
                _Game.ui:onEvent(self, self.onPressed)
            end
        end
        self.isBeingDragged = false
    end

    for i, child in ipairs(self.children) do
        child:mousereleased(x, y, button)
    end
end



function UIWidget:mousemoved(x, y, dx, dy)
    if self.isBeingDragged then
        self:setPos(_MousePos - self.dragOffset)
    end

    for i, child in ipairs(self.children) do
        child:mousemoved(x, y, dx, dy)
    end
end



return UIWidget