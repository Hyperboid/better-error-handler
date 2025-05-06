
---@class ErrorHandler.StackEntry : Class
---@field info debuginfo
---@field locals table
---@overload fun(...): ErrorHandler.StackEntry
local stackentry = Class()

stackentry.__tostring = function (self)
    return self:getSrc()..": in function "..(self.info.name or (
        "<"..self.info.short_src..":"..self.info.linedefined..">"
    ))
end

function stackentry:getSrc()
    if self.info.currentline == -1 then return self.info.short_src end
    return self:getFilePath()..":"..self.info.currentline
end

function stackentry:getFilePath()
    if self.info.currentline == -1 then return self.info.short_src end
    local src = self.info.source
    if src[1] == "=" or src[1] == "@" then
        src = Utils.sub(src, 2)
    end
    return src
end

function stackentry:init(info)
    self.info, self.locals = info, {}
    self.open = false
    self.sprite = Assets.getTexture("ui/errorhandler/arrow_right")
end

function stackentry:postInit()
    if next(self.locals) == nil then
        self.open = false
    end
end

function stackentry:draw()
    Draw.setColor(COLORS.white)
    love.graphics.push()
    self.transform = love.graphics.getTransformRef()
    local x, y = love.graphics.inverseTransformPoint(love.mouse.getPosition())
    if next(self.locals) ~= nil then
        if CollisionUtil.rectPoint(0, 0, 16, 16, x, y) then
            Draw.setColor(COLORS.yellow)
        end
        Draw.draw(self.sprite, 6+3, 6+2, self.open and (math.pi/2) or 0, 1, 1, 6, 6)
    end
    Draw.setColor(COLORS.white)
    love.graphics.translate(20,0)
    love.graphics.print(self:__tostring())
    local w = Assets.getFont("main_mono", 16):getWidth(self:getSrc())
    if self.info.short_src[1] ~= "[" and CollisionUtil.rectPoint(16, 0, w, 16, x, y) then
        love.graphics.setLineWidth(2)
        love.graphics.line(-1,16,w+1,16)
    end


    love.graphics.translate(20,0)
    if self.open then
        for key, value in pairs(self.locals) do
            love.graphics.translate(0,13)
    
            love.graphics.print(BetterError.dumpKey(key) .. " = " .. BetterError.dump(value))
        end
    end
    love.graphics.pop()
end

function stackentry:getHeight()
    if self.open then
        return 20 + (13 * (BetterError.countkeys(self.locals) + 0.5))
    end
    return 20
end

function stackentry:onClick(x,y, button)
    if button == 1 then
        if CollisionUtil.rectPoint(0, 0, 16, 16, x, y) then
            self.open = not self.open and (next(self.locals) ~= nil)
        elseif CollisionUtil.rectPoint(16, 0, Assets.getFont("main_mono", 16):getWidth(self:getSrc()), 16, x, y) then
            if love.filesystem.getRealDirectory(self:getFilePath()) then
                local full_path = love.filesystem.getRealDirectory(self:getFilePath()) .. "/" .. self:getFilePath()
                print(full_path)
                local uri = "vscode://file"..full_path..":"..self.info.currentline..":0"
                print(uri)
                -- TODO: Convince love.system.openURL("vscode://file"..full_path) to actually work
                os.execute("code --open-url \""..uri.."\"")
            end
        elseif not self.open then -- Prevent remaining cases, since they only happen when 
        end
    end
end

return stackentry