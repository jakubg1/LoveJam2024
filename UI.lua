local class = require "class"

local UI = class:derive("UI")

-- Place your imports here
local UIWidget = require("UIWidget")



function UI:new()
    local w_Window = UIWidget({name = "Window", type = "sprite", pos = {x = 500, y = 200}, size = {x = 300, y = 150}, sprite = _SPRITES.window, draggable = true, dragMaxY = 32})
    local w_HeaderText = UIWidget({name = "HeaderText", type = "text", pos = {x = 10, y = 2}, text = "Oh shit!!", font = _FONTS.windowHeader, color = _COLORS.white, shadow = true})
    local w_HeaderClose = UIWidget({name = "HeaderClose", type = "image", pos = {x = -5, y = 2}, align = {x = 1, y = 0}, parentAlign = {x = 1, y = 0}, image = _IMAGES.close})
    local w_HeaderMinimize = UIWidget({name = "HeaderMinimize", type = "image", pos = {x = -35, y = 2}, align = {x = 1, y = 0}, parentAlign = {x = 1, y = 0}, image = _IMAGES.minimize})
    local w_ContentBox = UIWidget({name = "ContentBox", type = "none", pos = {x = 5, y = 35}, size = {x = 290, y = 110}})
    local w_ContentText = UIWidget({name = "Text", type = "text", pos = {x = 10, y = 10}, text = "No more disk space.\nDelete Windows?", font = _FONTS.windowContents, color = _COLORS.black})
    local w_ContentButtonYes = UIWidget({name = "Button1", type = "sprite", pos = {x = 0, y = -24}, size = {x = 80, y = 26}, align = {x = 0.5, y = 0.5}, parentAlign = {x = 0.25, y = 1}, sprite = _SPRITES.button})
    local w_ContentButtonNo = UIWidget({name = "Button2", type = "sprite", pos = {x = 0, y = -24}, size = {x = 80, y = 26}, align = {x = 0.5, y = 0.5}, parentAlign = {x = 0.75, y = 1}, sprite = _SPRITES.button})
    local w_ContentButtonYesText = UIWidget({name = "ButtonTextYes", type = "text", pos = {x = 0, y = 0}, align = {x = 0.5, y = 0.5}, parentAlign = {x = 0.5, y = 0.5}, text = "Yes", font = _FONTS.windowContents, color = _COLORS.black})
    local w_ContentButtonNoText = UIWidget({name = "ButtonTextNo", type = "text", pos = {x = 0, y = 0}, align = {x = 0.5, y = 0.5}, parentAlign = {x = 0.5, y = 0.5}, text = "No", font = _FONTS.windowContents, color = _COLORS.black})

    w_Window:addChild(w_HeaderText)
    w_Window:addChild(w_HeaderClose)
    w_Window:addChild(w_HeaderMinimize)
    w_Window:addChild(w_ContentBox)
    w_ContentBox:addChild(w_ContentText)
    w_ContentBox:addChild(w_ContentButtonYes)
    w_ContentBox:addChild(w_ContentButtonNo)
    w_ContentButtonYes:addChild(w_ContentButtonYesText)
    w_ContentButtonNo:addChild(w_ContentButtonNoText)

    self.widgets = {w_Window}

    self.debugWidgetTree = {}
    self:generateDebugWidgetTree()
end



function UI:update(dt)
    
end



function UI:generateDebugWidgetTree(widget, indent)
    widget = widget or self.widgets[1]
    indent = indent or 0

    table.insert(self.debugWidgetTree, {widget = widget, indent = indent})
    for i, child in ipairs(widget.children) do
        self:generateDebugWidgetTree(child, indent + 1)
    end
end



function UI:draw()
    self.widgets[1]:draw()

    for i, w in ipairs(self.debugWidgetTree) do
        local y = (i - 1) * 20
        local hovered = _MouseX < 200 and _MouseY >= (i - 1) * 20 and _MouseY < i * 20

        local color = hovered and 1 or 0
        love.graphics.setColor(color, 0, 0, 0.5)
        love.graphics.rectangle("fill", 0, y, 200, 20)
        love.graphics.setColor(color, 0, 0, 1)
        love.graphics.rectangle("line", 0, y, 200, 20)
        _Game:drawText(w.widget.name, w.indent * 10, y, _FONTS.windowContents, _COLORS.white, true)

        if hovered then
            w.widget:drawDebug()
        end
    end
end



function UI:mousepressed(x, y, button)
	self.widgets[1]:mousepressed(x, y, button)
end



function UI:mousereleased(x, y, button)
	self.widgets[1]:mousereleased(x, y, button)
end



function UI:mousemoved(x, y, dx, dy)
	self.widgets[1]:mousemoved(x, y, dx, dy)
end



function UI:keypressed(key)
	local w = self.widgets[1]
	local wp = w:getGlobalPos()
	if key == "left" then
		w:setPos({x = wp.x - 5, y = wp.y})
	elseif key == "right" then
		w:setPos({x = wp.x + 5, y = wp.y})
	elseif key == "up" then
		w:setPos({x = wp.x, y = wp.y - 5})
	elseif key == "down" then
		w:setPos({x = wp.x, y = wp.y + 5})
	end
end



return UI