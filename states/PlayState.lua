--[[
    PlayState Class
    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The PlayState class is the bulk of the game, where the player actually controls the bird and
    avoids pipes. When the player collides with a pipe, we should go to the GameOver state, where
    we then go back to the main menu.
]]
PlayState = Class{__includes = BaseState}
PIPE_SPEED = 60
PIPE_WIDTH = 70
PIPE_HEIGHT = 288

BIRD_WIDTH = 38
BIRD_HEIGHT = 24

--debug
TEST_SPEED = 0
TEST_GAP = 0
function PlayState:init()
    self.bird = Bird()
    self.pipePairs = {}
    self.timer = 0
    self.score = 0  
    self.LEVEL_TIMER = 0
    self.PIPE_INTERVAL = 0
    self.PIPE_SPAWN_TIME = 5
    self.LEVEL1_TIME = 2 --changable
    self.LEVEL2_TIME = 5  --changable
    self.LEVEL3_TIME = 10  --changable
    self.ENDTIME = 15  --changable
    self.PIPE_INTERVAL_MAX = 0
    -- initialize our last recorded Y value for a gap placement to base other gaps off of
    self.lastY = -PIPE_HEIGHT + math.random(80) + 20
end

function PlayState:update(dt)
    -- update timer for pipe spawning
    self.timer = self.timer + dt
    self.PIPE_INTERVAL_MAX = ((self.LEVEL1_TIME + self.LEVEL2_TIME + self.LEVEL3_TIME)/3)-self.PIPE_SPAWN_TIME
    -- if score above 0 then start counting 
    if self.score > 0 then
        self.LEVEL_TIMER = self.LEVEL_TIMER + dt
        self.PIPE_INTERVAL = self.PIPE_INTERVAL + dt
    end

    --LEVEL LOOP
    if self.LEVEL_TIMER < self.LEVEL1_TIME then
        self.PIPE_SPAWN_TIME = 2
    elseif self.LEVEL_TIMER > self.LEVEL1_TIME  and self.LEVEL_TIMER < self.LEVEL2_TIME then  
        if self.PIPE_INTERVAL > self.PIPE_INTERVAL_MAX then
            if self.PIPE_SPAWN_TIME == 2 then
                self.PIPE_SPAWN_TIME = 3
            elseif self.PIPE_SPAWN_TIME == 3 then
                self.PIPE_SPAWN_TIME = 5
            elseif self.PIPE_SPAWN_TIME == 5 then
                self.PIPE_SPAWN_TIME = 3
            end
            --RESET INTERVAL
            self.PIPE_INTERVAL = 0
        end
    elseif self.LEVEL_TIMER > self.LEVEL2_TIME and self.LEVEL_TIMER < self.LEVEL3_TIME then
        if self.PIPE_INTERVAL > self.PIPE_INTERVAL_MAX then
            --Changes the SPAWN_TIME TO trigger loop
            if self.PIPE_SPAWN_TIME == 3 then
                self.PIPE_SPAWN_TIME = 4
            elseif self.PIPE_SPAWN_TIME == 4 then
                self.PIPE_SPAWN_TIME = 5
            elseif self.PIPE_SPAWN_TIME == 5 then
                self.PIPE_SPAWN_TIME = 4
            end
            --RESET INTERVAL
            self.PIPE_INTERVAL = 0
        end
    elseif self.LEVEL_TIMER > self.LEVEL3_TIME and self.LEVEL_TIMER < self.ENDTIME then
        if self.PIPE_INTERVAL > self.PIPE_INTERVAL_MAX then
            --Starts randomizing the spawn time above level 3
            self.PIPE_SPAWN_TIME = randomFloat(2.5,4,3)
            --RESET INTERVAL
            self.PIPE_INTERVAL = 0
        end
    elseif self.LEVEL_TIMER > self.ENDTIME then
        self.LEVEL_TIMER = 0
    end

    -- spawn a new pipe pair every second and a half -- changed to a variable
    if self.timer > self.PIPE_SPAWN_TIME then
        -- modify the last Y coordinate we placed so pipe gaps aren't too far apart
        -- no higher than 10 pixels below the top edge of the screen,
        -- and no lower than a gap length (90 pixels) from the bottom
        y = math.max(-PIPE_HEIGHT + 10, 
        math.min(self.lastY + math.random(-20, 20), VIRTUAL_HEIGHT - 90 - PIPE_HEIGHT))
        self.lastY = y
        -- add a new pipe pair at the end of the screen at our new Y
        table.insert(self.pipePairs, PipePair(y))

        -- reset timer
        self.timer = 0
    end
 
    -- for every pair of pipes..
    for k, pair in pairs(self.pipePairs) do
        -- score a point if the pipe has gone past the bird to the left all the way
        -- be sure to ignore it if it's already been scored
       -- remove after
        --TEST_GAP = pair.GAP_HEIGHT --remove after
        TEST_DIRECTION = pair.PIPE_DIRECTION_RANDOM
        if not pair.scored then 
            if pair.x + PIPE_WIDTH < self.bird.x then
                self.score = self.score + 1
                pair.scored = true
                sounds['score']:play()
                --added game play loop variable...
                self.LEVEL_TIMER = self.LEVEL_TIMER - (self.LEVEL_TIMER * (1/self.PIPE_SPAWN_TIME))
            elseif pair.x + PIPE_WIDTH > self.bird.x + 100 then
                -- starts moving the pipe at level 2
                if self.LEVEL_TIMER > self.LEVEL2_TIME then
                    --FLags wthe will_move to true 
                    if not pair.allowmove then
                        --starts upping the up and down speed of pipe at level 3
                        if self.LEVEL_TIMER > self.LEVEL3_TIME then
                            -- Make it faster 
                            pair.UP_DOWN_SPEED = randomFloat(0.5, 1, 3)
                            TEST_SPEED = pair.UP_DOWN_SPEED 
                        end
                        --Randomized in the Pipepair
                        if pair.PIPE_DIRECTION_RANDOM == 0 then
                            pair.boolup = false
                            pair.booldown = true
                        elseif pair.PIPE_DIRECTION_RANDOM == 1 then
                            pair.boolup = true
                            pair.booldown = false
                        end
                    pair.allowmove = true
                    else    

                    end
                end     
            end
        end
        -- Starts randomizing the gap height at level 1

        --[[
        if not pair.GAP_CHANGED then
            if pair.x + PIPE_WIDTH > VIRTUAL_WIDTH then
                pair.GAP_HEIGHT = math.random(90,100)
                pair.GAP_CHANGED = true
            end
        end

        --]]


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
   ---[[
    love.graphics.setFont(smallFont)
    love.graphics.print('Generated Y for Pair: '.. tostring(self.lastY), VIRTUAL_WIDTH - 150, 8)
    love.graphics.print('Timer: '.. tostring(self.LEVEL_TIMER), VIRTUAL_WIDTH - 150, 20)
  
    love.graphics.print('INTERVAL : '.. tostring(self.PIPE_INTERVAL), VIRTUAL_WIDTH - 150, 30)
    
    love.graphics.print('INTERVAL_MAX: '.. tostring(self.PIPE_INTERVAL_MAX), VIRTUAL_WIDTH - 150, 40)
 
    love.graphics.print('PIPE_SPEED: '.. tostring(TEST_SPEED), VIRTUAL_WIDTH - 150, 50)

    love.graphics.print('PIPE_SPAWN: '.. tostring(self.PIPE_SPAWN_TIME), VIRTUAL_WIDTH - 150, 60)
    love.graphics.print('PIPE DIRECTION '.. tostring(TEST_DIRECTION), VIRTUAL_WIDTH - 150, 70)
    love.graphics.print('GAP HEIGHT: '.. tostring(TEST_GAP), VIRTUAL_WIDTH - 150, 80)
    love.graphics.print('MAX: '.. tostring(-PIPE_HEIGHT + 10), VIRTUAL_WIDTH - 150, 90)
    love.graphics.print('MIN: '.. tostring(VIRTUAL_HEIGHT - 90 - PIPE_HEIGHT), VIRTUAL_WIDTH - 150, 100)
    --]] 
    self.bird:render()
    if IS_PAUSED == true then
        love.graphics.setFont(mediumFont)
        love.graphics.printf('Game Pause', 0, 100, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf('Press V again to unpause', 0, 120, VIRTUAL_WIDTH, 'center')
    end
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