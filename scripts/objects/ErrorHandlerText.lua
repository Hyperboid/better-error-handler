
---@class ErrorHandler.Text : Class
---@field info debuginfo
---@field locals table
---@overload fun(...): ErrorHandler.Text
local ErrorHandlerText = Class()

ErrorHandlerText.__tostring = function (self)
    return self.text
end

function ErrorHandlerText:init(text)
    self.lines = Utils.split(text, "\n")
    self.heading = table.remove(self.lines, 1)
    self.sprite = Assets.getTexture("ui/errorhandler/arrow_right") or Assets.getTexture("ui/flat_arrow_right")
    self.text = table.concat(self.lines, "\n")
    self.open = (#self.lines > 0)
end

function ErrorHandlerText:draw()
    Draw.setColor(COLORS.white)
    love.graphics.push()
    self.transform = love.graphics.getTransformRef()
    local x, y = love.graphics.inverseTransformPoint(love.mouse.getPosition())
    if #self.lines > 0 then
        if CollisionUtil.rectPoint(0, 0, 16, 16, x, y) then
            Draw.setColor(COLORS.yellow)
        end
        Draw.draw(self.sprite, 6+3, 6+2, self.open and (math.pi/2) or 0, 1, 1, 6, 6)
    end
    Draw.setColor(COLORS.white)
    love.graphics.translate(20,0)
    if #self.lines == 0 then
        love.graphics.scale(2)
        love.graphics.translate(0,8)
    end
    love.graphics.print(self.heading)

    love.graphics.translate(0,0)
    if self.open then
        love.graphics.translate(0,13)
        love.graphics.print(self.text)
    end
    love.graphics.pop()
end

function ErrorHandlerText:getHeight()
    if #self.lines == 0 then
        return 45
    end
    if self.open then
        return 20 + (13 * (#self.lines + 0.5))
    end
    return 20
end

function ErrorHandlerText:onClick(x,y, button)
    if button == 1 then
        if CollisionUtil.rectPoint(0, 0, 16, 16, x, y) then
            self.open = not self.open and (#self.lines > 0)
        end
    end
end

return ErrorHandlerText