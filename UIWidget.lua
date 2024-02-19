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
    local p = self:getGlobalPos()
    local s = self:getGlobalSize()
    return _MouseX >= p.x and _MouseY >= p.y and _MouseX <= p.x + s.x and _MouseY <= p.y + s.y
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



function UIWidget:drawDebug()
    local p = self:getGlobalPos()
    local s = self:getGlobalSize()

    love.graphics.setColor(1, 0, 0, 0.5)
    love.graphics.rectangle("fill", p.x, p.y, s.x, s.y)
end



function UIWidget:mousepressed(x, y, button)
    if button == 1 and self:isHovered() then
        self.pressed = true
        if self.draggable and (not self.dragMaxY or y - self:getGlobalPos().y <= self.dragMaxY) then
            self.isBeingDragged = true
            self.dragOffset = {x = _MouseX - self.pos.x, y = _MouseY - self.pos.y}
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
        self:setPos({x = _MouseX - self.dragOffset.x, y = _MouseY - self.dragOffset.y})
    end

    for i, child in ipairs(self.children) do
        child:mousemoved(x, y, dx, dy)
    end
end



return UIWidget