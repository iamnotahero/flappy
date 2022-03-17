--[[
    PipePair Class

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Used to represent a pair of pipes that stick together as they scroll, providing an opening
    for the player to jump through in order to score a point.
]]

PipePair = Class{}
-- size of the gap between pipes
local GAP_HEIGHT = 90
--Debugging Code
PIPE_UPPER_Y = 0
PIPE_LOWER_Y = 0
PIPE_Y = 0

function PipePair:init(y)
    -- flag to hold whether this pair has been scored (jumped through)
    self.scored = false
    -- initialize pipes past the end of the screen
    self.x = VIRTUAL_WIDTH + 32
    -- y value is for the topmost pipe; gap is a vertical shift of the second lower pipe
    self.y = y
    self.WILL_MOVE = false
    self.boolup = false
    self.booldown = false
    self.PIPE_DIRECTION_RANDOM = math.random(0,1)
    self.UP_DOWN_SPEED = 0.5
    -- instantiate two pipes that belong to this pair
    self.pipes = {
        ['upper'] = Pipe('top', self.y),
        ['lower'] = Pipe('bottom', self.y + PIPE_HEIGHT + GAP_HEIGHT)
    }
    
    
    -- whether this pipe pair is ready to be removed from the scene
    self.remove = false
end

function PipePair:update(dt)
    -- remove the pipe from the scene if it's beyond the left edge of the screen,
    -- else move it from right to left
    if self.y > -130 then
        self.boolup = false
        self.booldown = true
        
    elseif self.y < -240 then
        self.booldown = false
        self.boolup = true 
    end
    if self.x > -PIPE_WIDTH then
        self.x = self.x - PIPE_SPEED * dt
        if self.WILL_MOVE == true then
            if self.boolup == true then
                self.y = self.y + self.UP_DOWN_SPEED
                
            elseif self.booldown == true then
                self.y = self.y - self.UP_DOWN_SPEED
                
            end
        end
        self.pipes['upper'].y = self.y 
        self.pipes['lower'].y = self.y + PIPE_HEIGHT + GAP_HEIGHT
        self.pipes['lower'].x = self.x
        self.pipes['upper'].x = self.x

    else
        self.remove = true
    end
  
        --PIPE_UPPER_Y = self.pipes['upper'].y
        --PIPE_LOWER_Y = self.pipes['lower'].y
        --[[
        if self.pipes['upper'].y < -250 then
            boolup = false
            booldown = true
        elseif self.pipes['lower'].y > 250 then
            booldown = false 
            boolup = true 
        end
        
        if boolup == true then
            self.pipes['upper'].y = self.pipes['upper'].y - 1
            self.pipes['lower'].y = self.pipes['lower'].y - 1
        elseif booldown == true then
            self.pipes['upper'].y = self.pipes['upper'].y + 1
            self.pipes['lower'].y = self.pipes['lower'].y + 1
        end
        self.pipes['upper'].y = self.pipes['upper'].y
        self.pipes['lower'].y = self.pipes['lower'].y
        --]]
        --[[
        if self.y > -130 then
            boolup = false
            booldown = true
        elseif self.y < -250 then
            booldown = false
            boolup = true 
        end
        --[[
        if boolup == true then
            self.y = self.y + 1
        elseif booldown == true then
            self.y = self.y - 1
        end
       

        self.pipes['upper'].y = self.pipes['upper'].y
    



        --]]
        --]]
   


    for l, pipe in pairs(self.pipes) do  
        pipe:update(dt)
    end

end

function PipePair:render()
    for l, pipe in pairs(self.pipes) do
        pipe:render()
    end
end