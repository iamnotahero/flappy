--[[
    PlayState Class
    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The PlayState class is the bulk of the game, where the player actually controls the bird and
    avoids pipes. When the player collides with a pipe, we should go to the GameOver state, where
    we then go back to the main menu.
]]
PlayState = Class{__includes = BaseState}
require 'PipePair'
PIPE_SPEED = 60
PIPE_WIDTH = 70
PIPE_HEIGHT = 288

BIRD_WIDTH = 38
BIRD_HEIGHT = 24


function PlayState:init()
    self.bird = Bird()
    self.pipePairs = {}
    self.timer = 0
    self.score = 0  
    LEVEL_TIMER = 0
    self.PIPE_DIRECTION_RANDOM = math.random(0,1)
    self.PIPE_SPAWN_TIME = 5
    -- initialize our last recorded Y value for a gap placement to base other gaps off of
    self.lastY = -PIPE_HEIGHT + math.random(80) + 20
end

function PlayState:update(dt)
    -- update timer for pipe spawning
    -- improve code readablity isolation of pause
    self.timer = self.timer + dt
    LEVEL_TIMER = LEVEL_TIMER + dt
    -- spawn a new pipe pair every second and a half

    -- if LEVEL_TIMER is Above 15 and the score is above 10 it will start mixmatch the spawn time
    if LEVEL_TIMER >  15 and self.score > 2 then
        ---[[
        if self.score > 2 then
            self.PIPE_SPAWN_TIME = 3
            if self.PIPE_DIRECTION_RANDOM == 0 then
                BOOL_UP_PUBLIC = false
                BOOL_DOWN_PUBLIC = true
            else
                BOOL_UP_PUBLIC = true
                BOOL_DOWN_PUBLIC = false
            end
        end
        --]]
        -- Switch if it reaches 15 seconds
        if self.PIPE_SPAWN_TIME == 2 then
            self.PIPE_SPAWN_TIME = 5
        elseif self.PIPE_SPAWN_TIME == 5 then
            self.PIPE_SPAWN_TIME = 2
        end

        --RESET LEVEL_TIMER
        LEVEL_TIMER = 0
    end

    if self.timer > self.PIPE_SPAWN_TIME then
        -- modify the last Y coordinate we placed so pipe gaps aren't too far apart
        -- no higher than 10 pixels below the top edge of the screen,
        -- and no lower than a gap length (90 pixels) from the bottom
        if self.score <= 2 then
        y = math.max(-PIPE_HEIGHT + 10, 
            math.min(self.lastY + math.random(-20, 20), VIRTUAL_HEIGHT - 90 - PIPE_HEIGHT))
        self.lastY = y
        elseif self.score > 2 and self.score <= 5 then
        y = math.max(-PIPE_HEIGHT + 10, 
            math.min(self.lastY + math.random(20, 50), VIRTUAL_HEIGHT - 90 - PIPE_HEIGHT))
        self.lastY = y
        elseif self.score > 5  and self.score <= 10 then
        y = math.max(-PIPE_HEIGHT + 10, 
            math.min(self.lastY + math.random(-50, -20), VIRTUAL_HEIGHT - 90 - PIPE_HEIGHT))
        self.lastY = y
        elseif self.score > 10 then
        y = math.max(-PIPE_HEIGHT + 10, 
            math.min(self.lastY + math.random(-20, 20), VIRTUAL_HEIGHT - 90 - PIPE_HEIGHT))
        self.lastY = y
        end

       

        -- add a new pipe pair at the end of the screen at our new Y
        table.insert(self.pipePairs, PipePair(y))

        -- reset timer
        self.timer = 0
    end
 
    -- for every pair of pipes..
    for k, pair in pairs(self.pipePairs) do
        -- score a point if the pipe has gone past the bird to the left all the way
        -- be sure to ignore it if it's already been scored
        if not pair.scored then
            
            if pair.x + PIPE_WIDTH < self.bird.x then
                self.score = self.score + 1
                pair.scored = true
                sounds['score']:play()
                self.PIPE_DIRECTION_RANDOM = math.random(0,1)
            else
               
            end
        end

        -- update position of pair
        pair:update(dt)
    end

    -- we need this second loop, rather than deleting in the previous loop, because
    -- modifying the table in-place without explicit keys will result in skipping the
    -- next pipe, since all implicit keys (numerical indices) are automatically shifted
    -- down after a table removal
    for k, pair in pairs(self.pipePairs) do
        if pair.remove then
            table.remove(self.pipePairs, k)
        end
    end

    -- simple collision between bird and all pipes in pairs
    for k, pair in pairs(self.pipePairs) do
        for l, pipe in pairs(pair.pipes) do
            if self.bird:collides(pipe) then
                sounds['explosion']:play()
                sounds['hurt']:play()
                BOOL_UP_PUBLIC = false
                BOOL_DOWN_PUBLIC = false
                gStateMachine:change('score', {
                    score = self.score
                })
            end
        end
    end

    -- update bird based on gravity and input

    self.bird:update(dt)
    
    -- reset if we get to the ground
    if self.bird.y > VIRTUAL_HEIGHT - 15 then
        sounds['explosion']:play()
        sounds['hurt']:play()
        BOOL_UP_PUBLIC = false
        BOOL_DOWN_PUBLIC = false
        gStateMachine:change('score', {
            score = self.score
        })
    end
end

function PlayState:render()
    for k, pair in pairs(self.pipePairs) do
        pair:render()
    end

    love.graphics.setFont(flappyFont)
    love.graphics.print('Score: ' .. tostring(self.score), 8, 8)
    love.graphics.setFont(smallFont)
    love.graphics.print('Generated Y for Pair: '.. tostring(self.lastY), VIRTUAL_WIDTH - 150, 8)
    love.graphics.print('Timer: '.. tostring(LEVEL_TIMER), VIRTUAL_WIDTH - 150, 20)
    ---[[
    love.graphics.print('PIPE_Y: '.. tostring(PIPE_Y), VIRTUAL_WIDTH - 150, 30)
    love.graphics.print('PIPE_UPPER_Y: '.. tostring(PIPE_UPPER_Y), VIRTUAL_WIDTH - 150, 40)
    love.graphics.print('PIPE_LOWER_Y: '.. tostring(PIPE_LOWER_Y), VIRTUAL_WIDTH - 150, 50)
    --]]
    love.graphics.print('PIPE_SPAWN: '.. tostring(PIPE_SPAWN_TIME), VIRTUAL_WIDTH - 150, 60)
    love.graphics.print('MAX: '.. tostring(-PIPE_HEIGHT + 10), VIRTUAL_WIDTH - 150, 70)
    love.graphics.print('MIN: '.. tostring(VIRTUAL_HEIGHT - 90 - PIPE_HEIGHT), VIRTUAL_WIDTH - 150, 80)
    
    


    
    
    self.bird:render()
end

--[[
    Called when this state is transitioned to from another state.
]]
function PlayState:enter()
    -- if we're coming from death, restart scrolling
    scrolling = true
end

--[[
    Called when this state changes to another state.
]]
function PlayState:exit()
    -- stop scrolling for the death/score screen
    scrolling = false
end