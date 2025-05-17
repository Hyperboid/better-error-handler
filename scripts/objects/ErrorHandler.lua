--[[
---@return string
local function stripTo(str, char)
    while #str > 1 and str:sub(-1,-1) ~= "." do str = str:sub(1,-2) end
    return str:sub(1,-2)
end
local path = stripTo(..., ".")
local hump_path = stripTo(path, ".").. ".hump"
--]]


---@class ErrorHandler : Subsystem
---@field traceback ErrorHandler.StackEntry[]
---@overload fun() : ErrorHandler
local ErrorHandler, super = Class("Subsystem")

---@param thread thread?
function ErrorHandler.getTraceback(stack_depth, thread)
    local traceback = {}
    stack_depth = stack_depth or 3 -- Start at 3 to skip the error handler itself
    while stack_depth < 1000 do
        stack_depth = stack_depth + 1
        -- local stackentry = setmetatable({info = debug.getinfo(stack_depth), locals = {}}, stackentry_mt)
        local stackentry
        if thread then
            stackentry = StackEntry(debug.getinfo(thread, stack_depth))
        else
            stackentry = StackEntry(debug.getinfo(stack_depth))
        end
        if not stackentry.info then break end
        local local_index = 0
        -- It's incredibly unlikely, albeit technically possible, to have more than 1000 locals. You'd need about 6 levels of do...end.
        while local_index < 1000 do
            local_index = local_index + 1
            local name, val
            if thread then
                print(stack_depth)
                if not pcall(debug.getlocal, thread, stack_depth, local_index) then
                    break
                end
                name, val = debug.getlocal(thread, stack_depth, local_index)
            else
                name, val = debug.getlocal(stack_depth, local_index)
            end
            if not name then break end
            if stackentry.locals[name] == nil then
                stackentry.locals[name] = val
            end
        end
        stackentry:postInit()
        table.insert(traceback, stackentry)
    end
    return traceback
end

function ErrorHandler:init()
    super.init(self)
    -- self.sleep_time = 0.05
    self.scroll = 0
end

function ErrorHandler:load(msg)
    self.traceback = self.getTraceback()
    if FAILED_COROUTINE then
        local thread = FAILED_COROUTINE
        FAILED_COROUTINE = nil
        local ok, tb = pcall(self.getTraceback, -1, thread)
        if not ok then
            print(tb)
            love.timer.sleep(3)
        end
        self.traceback = Utils.mergeMultiple({ErrorHandlerText("Coroutine Traceback")}, tb, {ErrorHandlerText(""), ErrorHandlerText("Main Traceback")}, self.traceback)
    elseif COROUTINE_TRACEBACK then
        table.insert(self.traceback, 1, ErrorHandlerText("Coroutine Traceback:\n"..COROUTINE_TRACEBACK))
    end
    CRASH_TRACEBACK = self.traceback
    -- Reset state.
    if love.mouse then
        love.mouse.setVisible(true)
        love.mouse.setGrabbed(false)
        love.mouse.setRelativeMode(false)
        if love.mouse.isCursorSupported() then
            love.mouse.setCursor()
        end
    end
    if love.joystick then
        -- Stop all joystick vibrations.
        for i,v in ipairs(love.joystick.getJoysticks()) do
            v:setVibration()
        end
    end
    if love.audio then love.audio.stop() end
    love.graphics.reset()
    love.graphics.setCanvas()

    print("Error: "..debug.traceback(msg or 2, msg and 2 or nil))
    if Input then Input.clear(nil, true) end
    self.msg = msg
    return super.load(self, msg)
end

function ErrorHandler:quit(...)
    return super.quit(self)
end

function ErrorHandler:update()
    Kristal.DebugSystem:update()
end

function ErrorHandler:drawScreenshot()
    love.graphics.push()
    love.graphics.translate(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
    love.graphics.scale(Kristal.getGameScale())
    love.graphics.translate(-SCREEN_WIDTH / 2, -SCREEN_HEIGHT / 2)
    Draw.draw(SCREEN_CANVAS)
    love.graphics.pop()
end

function ErrorHandler:draw()
    love.graphics.setFont(Assets.getFont("main_mono",16))
    love.graphics.origin()
    Draw.setColor(COLORS.white(0.5))
    self:drawScreenshot()
    Draw.setColor(COLORS.white)
    love.graphics.scale(Kristal.getGameScale())
    love.graphics.push()
    love.graphics.translate(30,20)
    love.graphics.translate(0, (self.scroll * -10))
    for index, entry in ipairs(self.traceback) do
        entry:draw()
        love.graphics.translate(20,0)
        love.graphics.translate(0,entry:getHeight())
        love.graphics.translate(-20,0)
    end --]]
    love.graphics.pop()
    love.graphics.setColor(0,0,0,1)
    love.graphics.rectangle("fill", 0,0,love.graphics.getWidth(), 20)
    love.graphics.setColor(1,1,1,1)
    love.graphics.print("Error: "..(self.msg or "<Unknown>"))
    -- Kristal.Stage:draw()
end

function ErrorHandler:keypressed(key)
    if key == "escape" then
        love.event.quit("reload")
    elseif key == "c" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
    else
        -- Kristal.DebugSystem:onKeyPressed(key, false)
    end
end

function ErrorHandler:keyreleased(key)
    -- Kristal.DebugSystem:onKeyReleased(key)
end

function ErrorHandler:processEvent(name, ...)
    -- print(name,Utils.unpack{...})
    return super.processEvent(self, name, ...)
end

function ErrorHandler:wheelmoved(x, y)
    self.scroll = Utils.clamp(self.scroll - y, 0, math.huge)
end

function ErrorHandler:mousepressed(sx,sy,button)
    sy = sy / Kristal.getGameScale()
    sx = sx / Kristal.getGameScale()
    local y = 20 + (self.scroll * -10)
    for _, entry in ipairs(self.traceback) do
        if CollisionUtil.rectPoint(-50, y, 100, entry:getHeight(), 0, sy) then
            entry:onClick(sx-30,sy-y,button)
            return
        end
        y = y + entry:getHeight()
    end
end

return ErrorHandler
