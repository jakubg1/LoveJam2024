local class = require "class"

local UI = class:derive("UI")

-- Place your imports here
local UIWidget = require("UIWidget")



function UI:new()
    local w_Desktop = UIWidget({name = "Desktop", type = "image", pos = {x = 0, y = 0}, size = {x = 1280, y = 720}, image = _IMAGES.desktop})

    --w_Desktop:addChild(self:makeWindow({x = 500, y = 200}, {x = 300, y = 150}, "Oh shit!!", "No more disk space.\nDelete Windows?", {"Yes", "yes"}, {"No", "no"}, true, true))
    --w_Desktop:addChild(self:makeWindow({x = 200, y = 400}, {x = 200, y = 100}, "Hello World!", "Close this window", nil, nil, true, false))
    --w_Desktop:addChild(self:makeWindow({x = 300, y = 50}, {x = 250, y = 100}, "", "You can't close this window", nil, nil, false, false))

    local w_Menu = self:makeWindow({x = 490, y = 160}, {x = 300, y = 400}, "Main Menu")

    --local w_MenuText = UIWidget({name = "Text", type = "text", pos = {x = 0, y = 10}, align = {x = 0.5, y = 0}, parentAlign = {x = 0.5, y = 0}, text = "Welcome to the game!", font = _FONTS.windowContents, color = _COLORS.black})
    --w_Menu:getChild("ContentBox"):addChild(w_MenuText)
    local w_MenuText2 = UIWidget({name = "Text", type = "text", pos = {x = 0, y = 10}, align = {x = 0.5, y = 0}, parentAlign = {x = 0.5, y = 0}, text = "The desktop is under attack!\n\nIn order to rescue it and bring back the peace in the Paintland, (you can see it in the background), you must...\n\nOkay, enough of that dumb talk. Just do what the windows tell you to do, okay? Everything will be fine.", font = _FONTS.windowContents, color = _COLORS.black, lineWidth = 280, lineSquish = 0.25})
    w_Menu:getChild("ContentBox"):addChild(w_MenuText2)
    local w_MenuText3 = UIWidget({name = "Text", type = "text", pos = {x = 0, y = 220}, align = {x = 0.5, y = 0}, parentAlign = {x = 0.5, y = 0}, text = "High Score:", font = _FONTS.windowContents, color = _COLORS.black, lineWidth = 280, lineSquish = 0.25})
    w_Menu:getChild("ContentBox"):addChild(w_MenuText3)
    local w_MenuText4 = UIWidget({name = "Text", type = "text", pos = {x = 0, y = 240}, align = {x = 0.5, y = 0}, parentAlign = {x = 0.5, y = 0}, text = "0", font = _FONTS.windowContentsBold, color = _COLORS.black, lineWidth = 280, lineSquish = 0.25})
    w_Menu:getChild("ContentBox"):addChild(w_MenuText4)
    local w_Button = self:makeButton("Start Game!", "start", 0.5)
    w_Button.size.x = 150
    w_Menu:getChild("ContentBox"):addChild(w_Button)
    w_Menu:setFocus(true)

    w_Desktop:addChild(w_Menu)



    self.rootWidget = w_Desktop

    self.debugWidgetTree = {}
    self:generateDebugWidgetTree()
end



function UI:update(dt)
    
end



function UI:makeButton(name, event, alignX)
    local w_Button = UIWidget({name = "Button_" .. event, type = "sprite", pos = {x = 0, y = -24}, size = {x = 80, y = 26}, align = {x = 0.5, y = 0.5}, parentAlign = {x = alignX, y = 1}, sprite = _SPRITES.button, spritePressed = _SPRITES.buttonPressed, onPressed = event})
    local w_ButtonText = UIWidget({name = "ButtonText_" .. event, type = "text", pos = {x = 0, y = 0}, align = {x = 0.5, y = 0.5}, parentAlign = {x = 0.5, y = 0.5}, text = name, font = _FONTS.windowContents, color = _COLORS.black, colorUnfocused = _COLORS.gray})

    w_Button:addChild(w_ButtonText)

    return w_Button
end



function UI:makeWindow(pos, size, title, content, button1, button2, closeable, minimizable)
    -- Base window
    local w_Window = UIWidget({name = "Window", type = "sprite", pos = {x = pos.x, y = pos.y}, size = {x = size.x, y = size.y}, sprite = _SPRITES.window, spriteUnfocused = _SPRITES.windowDisabled, draggable = true, dragMaxY = 32, focusMovesToFront = true})
    local w_HeaderText = UIWidget({name = "HeaderText", type = "text", pos = {x = 10, y = 2}, text = title, font = _FONTS.windowHeader, color = _COLORS.white, colorUnfocused = _COLORS.lightGray, shadow = true})
    local w_ContentBox = UIWidget({name = "ContentBox", type = "none", pos = {x = 5, y = 35}, size = {x = size.x - 10, y = size.y - 40}})

    w_Window:addChild(w_HeaderText)
    w_Window:addChild(w_ContentBox)

    -- Content
    if content then
        local w_ContentText = UIWidget({name = "Text", type = "text", pos = {x = 10, y = 10}, text = content, font = _FONTS.windowContents, color = _COLORS.black})
        w_ContentBox:addChild(w_ContentText)
    end

    -- Buttons (0, 1, or 2)
    if button1 and button2 then
        w_ContentBox:addChild(self:makeButton(button1[1], button1[2], 0.25))
        w_ContentBox:addChild(self:makeButton(button2[1], button2[2], 0.75))
    elseif button1 then
        w_ContentBox:addChild(self:makeButton(button1[1], button1[2], 0.5))
    end

    -- Close button
    local w_HeaderClose
    if closeable then
        w_HeaderClose = UIWidget({name = "HeaderClose", type = "image", pos = {x = -5, y = 2}, align = {x = 1, y = 0}, parentAlign = {x = 1, y = 0}, image = _IMAGES.close, imagePressed = _IMAGES.closePressed, imageUnfocused = _IMAGES.closeDisabled, onPressed = "close"})
    else
        w_HeaderClose = UIWidget({name = "HeaderClose", type = "image", pos = {x = -5, y = 2}, align = {x = 1, y = 0}, parentAlign = {x = 1, y = 0}, image = _IMAGES.closeDisabled})
    end
    w_Window:addChild(w_HeaderClose)

    -- Minimize button
    if minimizable then
        local w_HeaderMinimize = UIWidget({name = "HeaderMinimize", type = "image", pos = {x = -35, y = 2}, align = {x = 1, y = 0}, parentAlign = {x = 1, y = 0}, image = _IMAGES.minimize, imagePressed = _IMAGES.minimizePressed, imageUnfocused = _IMAGES.minimizeDisabled, onPressed = "minimize"})
        w_Window:addChild(w_HeaderMinimize)
    end

    return w_Window
end



function UI:generateDebugWidgetTree(widget, indent)
    if not widget then
        self.debugWidgetTree = {}
    end
    widget = widget or self.rootWidget
    indent = indent or 0

    table.insert(self.debugWidgetTree, {widget = widget, indent = indent})
    for i, child in ipairs(widget.children) do
        self:generateDebugWidgetTree(child, indent + 1)
    end
end



function UI:onEvent(caller, event)
    local window = caller:findIndirectParentThatIsAChildOf(self.rootWidget)
    window:moveToFront()
    print(caller, event, window)
    if event == "close" then
        window:close()
    end
end



function UI:draw()
    self.rootWidget:draw()

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

    --local hoveredWindow = self.rootWidget:getFrontmostHoveredChild()
    --if hoveredWindow then
    --    hoveredWindow:drawDebug()
    --end
end



function UI:mousepressed(x, y, button)
	self.rootWidget:mousepressed(x, y, button)
end



function UI:mousereleased(x, y, button)
	self.rootWidget:mousereleased(x, y, button)
end



function UI:mousemoved(x, y, dx, dy)
	self.rootWidget:mousemoved(x, y, dx, dy)
end



function UI:keypressed(key)
	local w = self.rootWidget
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