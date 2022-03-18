--[[
    PipePair Class

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Used to represent a pair of pipes that stick together as they scroll, providing an opening
    for the player to jump through in order to score a point.
]]

PipePair = Class{}

function PipePair:init(y)
    -- flag to hold whether this pair has been scored (jumped through)
    self.scored = false
    -- initialize pipes past the end of the screen
    self.x = VIRTUAL_WIDTH + 32
    -- y value is for the topmost pipe; gap is a vertical shift of the second lower pipe
    self.y = y
    --Flag to trigger for changed gap
    self.allowmove = false
    --self.GAP_CHANGED = false
    --Flags to trigger for directions
    self.boolup = false
    self.booldown = false
    -- Randomized Direction of Moving Pipe
    self.PIPE_DIRECTION_RANDOM = math.random(0,1)
    -- Moving Pipe Speed
    self.UP_DOWN_SPEED = 0.2 --0.2
    -- size of the gap between pipes
    self.GAP_HEIGHT = math.random(90,100)
    -- instantiate two pipes that belong to this pair
    self.pipes = {
        ['upper'] = Pipe('top', self.y),
        ['lower'] = Pipe('bottom', self.y + PIPE_HEIGHT + self.GAP_HEIGHT)
    }
    
    
    -- whether this pipe pair is ready to be removed from the scene
    self.remove = false
end

function PipePair:update(dt)
    -- remove the pipe from the scene if it's beyond the left edge of the screen,
    -- else move it from right to left
    --check if pipe y if above else below chance of running the code when pipe is spawned beyond the parameter and will start early than specifed i kept it, more complexity to the level
    if self.y > -120  then
        self.booldown = false
        self.boolup = true 
    elseif self.y <= -278 then
        self.boolup = false
        self.booldown = true
    end
    if self.x > -PIPE_WIDTH then
        self.x = self.x - PIPE_SPEED * dt
        if self.boolup == true then
            self.y = self.y - self.UP_DOWN_SPEED
                
        elseif self.booldown == true then
            self.y = self.y + self.UP_DOWN_SPEED
                
        end
        self.pipes['upper'].y = self.y 
        self.pipes['lower'].y = self.y + PIPE_HEIGHT + self.GAP_HEIGHT
        self.pipes['lower'].x = self.x
        self.pipes['upper'].x = self.x

    else
        self.remove = true
    end

    for l, pipe in pairs(self.pipes) do  
        pipe:update(dt)
    end

end

function PipePair:render()
    for l, pipe in pairs(self.pipes) do
        pipe:render()
    end
end