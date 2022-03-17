--[[
    Pipe Class
    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The Pipe class represents the pipes that randomly spawn in our game, which act as our primary obstacles.
    The pipes can stick out a random distance from the top or bottom of the screen. When the player collides
    with one of them, it's game over. Rather than our bird actually moving through the screen horizontally,
    the pipes themselves scroll through the game to give the illusion of player movement.
]]

Pipe = Class{}

-- since we only want the image loaded once, not per instantation, define it externally
local PIPE_IMAGE = love.graphics.newImage('pipe.png')
--PIPE_MAIN_Y = 0
function Pipe:init(orientation, y)
    self.x = VIRTUAL_WIDTH + 64
    self.y = y
    --[[
    self.boolup = false
    self.booldown = true
    --]]
    self.width = PIPE_WIDTH
    self.height = PIPE_HEIGHT

    self.orientation = orientation
end

function Pipe:update(dt)
    --[[

    self.y = self.y - 0.2 
    if self.y < 90 then
        self.boolup = false
        self.booldown = true
    elseif self.y > 200 then
        self.booldown = false
        self.boolup = true 
    end
    if self.boolup == true then
        self.y = self.y - 0.2 
    elseif self.booldown == true then
        self.y = self.y + 0.2
    end
    --]]
end

function Pipe:render()
    love.graphics.draw(PIPE_IMAGE, self.x, 

        -- shift pipe rendering down by its height if flipped vertically
        (self.orientation == 'top' and self.y + PIPE_HEIGHT or self.y), 

        -- scaling by -1 on a given axis flips (mirrors) the image on that axis
        0, 1, self.orientation == 'top' and -1 or 1)
end