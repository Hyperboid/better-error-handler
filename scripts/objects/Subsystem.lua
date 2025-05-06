local class = Class
---@class Subsystem : Class
local Subsystem = class()

local default_font = love.graphics.getFont()

function Subsystem:init()
    self.sleep_time = 0.01
    self.forward_events = true
end

function Subsystem:load(...)
    
end

function Subsystem:run(...)
    self:load(...)
    return function ()
        local old_active_subsystem = ACTIVE_SUBSYSTEM
        ACTIVE_SUBSYSTEM = self
        local value = self:mainLoop()
        ACTIVE_SUBSYSTEM = old_active_subsystem
        return value
    end
end

function Subsystem:processEvent(name, ...)
    if self[name] then
        self[name](self, ...)
    end
end

function Subsystem:mainLoop()
    -- Process events.
    if love.event then
        love.event.pump()
        for name, a,b,c,d,e,f in love.event.poll() do
            if name == "quit" then
                if not self:quit() then
                    return a or 0
                end
            end
            self:processEvent(name,a,b,c,d,e,f)
        end
    end

    local dt = 0
    -- Update dt, as we'll be passing it to update
    if love.timer then dt = love.timer.step() end

    -- Call update and draw
    self:update(dt) -- will pass 0 if love.timer is disabled

    if love.graphics and love.graphics.isActive() then
        love.graphics.origin()
        love.graphics.clear(love.graphics.getBackgroundColor())

        love.graphics.setFont(default_font)
        self:draw()

        love.graphics.present()
    end
    love.timer.sleep(self.sleep_time)
end
love.handlers = love.handlers or {}
function Subsystem:update(...)  end
function Subsystem:draw(...) love.graphics.print("No draw impl") end
function Subsystem:mousepressed(...) if self.forward_events then return love.handlers.mousepressed(...) end end
function Subsystem:mousereleased(...) if self.forward_events then return love.handlers.mousereleased(...) end end
function Subsystem:wheelmoved(...) if self.forward_events then return love.handlers.wheelmoved(...) end end
function Subsystem:touchpressed(...) if self.forward_events then return love.handlers.touchpressed(...) end end
function Subsystem:touchreleased(...) if self.forward_events then return love.handlers.touchreleased(...) end end
function Subsystem:touchmoved(...) if self.forward_events then return love.handlers.touchmoved(...) end end
function Subsystem:joystickpressed(...) if self.forward_events then return love.handlers.joystickpressed(...) end end
function Subsystem:joystickreleased(...) if self.forward_events then return love.handlers.joystickreleased(...) end end
function Subsystem:joystickaxis(...) if self.forward_events then return love.handlers.joystickaxis(...) end end
function Subsystem:joystickhat(...) if self.forward_events then return love.handlers.joystickhat(...) end end
function Subsystem:gamepadpressed(...) if self.forward_events then return love.handlers.gamepadpressed(...) end end
function Subsystem:gamepadreleased(...) if self.forward_events then return love.handlers.gamepadreleased(...) end end
function Subsystem:gamepadaxis(...) if self.forward_events then return love.handlers.gamepadaxis(...) end end
function Subsystem:joystickadded(...) if self.forward_events then return love.handlers.joystickadded(...) end end
function Subsystem:joystickremoved(...) if self.forward_events then return love.handlers.joystickremoved(...) end end
function Subsystem:focus(...) if self.forward_events then return love.handlers.focus(...) end end
function Subsystem:resize(...) if self.forward_events then return love.handlers.resize(...) end end
function Subsystem:mousefocus(...) if self.forward_events then return love.handlers.mousefocus(...) end end
function Subsystem:visible(...) if self.forward_events then return love.handlers.visible(...) end end
function Subsystem:keypressed(...) if self.forward_events then return love.handlers.keypressed(...) end end
function Subsystem:threaderror(...) if self.forward_events then return love.handlers.threaderror(...) end end
function Subsystem:lowmemory(...) if self.forward_events then return love.handlers.lowmemory(...) end end
function Subsystem:keyreleased(...) if self.forward_events then return love.handlers.keyreleased(...) end end
function Subsystem:textinput(...) if self.forward_events then return love.handlers.textinput(...) end end
function Subsystem:filedropped(...) if self.forward_events then return love.handlers.filedropped(...) end end
function Subsystem:textedited(...) if self.forward_events then return love.handlers.textedited(...) end end
function Subsystem:directorydropped(...) if self.forward_events then return love.handlers.directorydropped(...) end end
function Subsystem:mousemoved(...) if self.forward_events then return love.handlers.mousemoved(...) end end
function Subsystem:displayrotated(...) if self.forward_events then return love.handlers.displayrotated(...) end end
function Subsystem:quit(...) if self.forward_events then return love.handlers.quit(...) end end

return Subsystem