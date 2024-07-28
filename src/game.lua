game = {}

-- game init 
function game:init(debug, start_state, _ballons)
    game.debug = debug
    
    -- stat trackers
    game.score = 0
    game.starting_health = 1
    game.health = game.starting_health
    game.playing = true
    game.wave = 1
    game.wave_active = true
    game.wave_length = 31
    game.rest_length = 11

    -- get font for text 
    game.font = love.graphics.newFont("assets/fonts/PixelOperator8.ttf", 30)

    -- get relative game time
    game.start = love.timer.getTime()
    game.time = love.timer.getTime() - self.start

    -- store game state 
    
    game.state = start_state

    -- get the ballon object to control the ballons
    game.ballons = _ballons 

    -- spawn table
    game.spawn_chance = 20
    game.spawn_table = {}
    game.spawn_table["red"] = 5
    game.spawn_table["green"] = 0
    game.spawn_table["blue"] = 0
end 

-- game update
function game:update(dt)
    game:wave_update(dt)
    if game.wave_active then 
        game:spawn_ballons(dt) 
    end
end

-- reset time 
function game:reset_time()
    game.start = love.timer.getTime()
    game.time = love.timer.getTime() - self.start
end 

-- spawn ballons
function game:spawn_ballons(dt)
    local val = math.random(2000)
    if val < game.spawn_chance then 
        game:spawn_random_ballon()
    end 
end 

-- spawn random ballon
function game:spawn_random_ballon()
    game.ballons:add_ballon(game:select_random_ballon())
end

-- select a random ballon from the table 
function game:select_random_ballon()
    local total_weight = 0 
    for k, v in pairs(game.spawn_table) do
        total_weight = total_weight + v
    end 
    local b_type = ""
    local rand_val = math.random(1, total_weight)
    for k, v in pairs(game.spawn_table) do 
        rand_val = rand_val - v
        if rand_val <= 0 then 
            return k
        end 
    end 
    return "red"
end 

-- spawn bonus 
function game:spawn_bonus_ballons()
    if (game.wave - 1) % 5 == 0 then
        game.ballons:add_ballon("reload_boost")
        game.ballons:add_ballon("ammo_boost")
    else 
        game.ballons:add_ballon("health")
        game.ballons:add_ballon("point")
    end
end 

-- increase spawn chance
function game:update_chance()
    if self.wave > 2 then 
        game.spawn_table["blue"] = game.spawn_table["blue"] + 1
    end
    if self.wave > 1 then 
        game.spawn_table["green"] = game.spawn_table["green"] + 1
    end
    game.spawn_table["red"] = game.spawn_table["red"] + 1    
    game.spawn_chance = game.spawn_chance * 1.05
end 

-- wave update 
function game:wave_update(dt)
    self.time = love.timer.getTime() - self.start
    ballons:update(dt, self)
    game:control_waves(dt)
    if self.health <= 0 then 
        game:reset()
        self.ballons:clear()
        self.state = "post_game"
    end
end 

-- reset game values
function game:reset()
    -- stat trackers
    game.score = 0
    game.health = self.starting_health
    game.playing = true
    game.wave = 1
    game.wave_active = true

    -- get relative game time
    game.start = love.timer.getTime()
    game.time = love.timer.getTime() - self.start

    game.spawn_table = {}
    game.spawn_table["red"] = 5
    game.spawn_table["green"] = 0
    game.spawn_table["blue"] = 0
end 

-- function control waves
function game:control_waves(dt)
    if self.time >= self.wave_length and self.wave_active then 
        self.start = love.timer.getTime()
        self.time = self.start
        self.wave = self.wave + 1
        self.ballons:clear()
        game:spawn_bonus_ballons()
        self.wave_active = false
    elseif self.time >= self.rest_length and not self.wave_active then 
        self.start = love.timer.getTime()
        self.time = self.start
        game:update_chance()
        self.wave_active = true
    end
end 

-- game draw
function game:draw()
    -- draw stats
    local score_tracker = "Score: " .. self.score
    love.graphics.print(score_tracker, self.font, 10, 10)
    local health_tracker = "Health: " .. self.health 
    love.graphics.print(health_tracker, self.font, 560, 10)
    -- format time and draw
    local time_tracker
    if self.wave_active then 
        local clock_time = math.floor(self.time % 60)
        if clock_time ~= 0 then 
            time_tracker = string.format("%02.0f", math.floor(self.time % 60))
        else
            time_tracker = string.format("Go")
        end 
    else
        time_tracker = string.format("%02.0f", math.floor(-1 * ((self.time % 60) - self.rest_length)))
    end 
    love.graphics.print(time_tracker, self.font, 375, 50)
    -- draw wave counter 
    local wave_tracker
    if self.wave_active then 
        wave_tracker = string.format("Wave %d", self.wave)
        love.graphics.print(wave_tracker, self.font, 320, 10)
    else 
        wave_tracker = "Prepare"
        love.graphics.print(wave_tracker, self.font, 310, 10)
    end
end 

-- add score if ballon is hit
function game:success_check(x, y, button, shoot, pointer, ballons)
    if button == 1 and shoot.current_ammo >= 0 then
        pointer:set_shooting(true)
        local hit_ballon = false
        for i, v in ipairs(ballons.list) do
            if pointer:check_shot(v, shoot.current_ammo) and not hit_ballon then 
                game:add_score(v:get_value())
                local effect = ballons:destroy_ballon(i)
                if effect == "health" then 
                    game:add_health(1)
                end
                if effect == "reload_boost" then
                    shoot:boost_reload(0.65)
                end 
                if effect == "ammo_boost" then
                    shoot:ammo_increase(1)
                end 
                if not self.wave_active then 
                    ballons:clear()
                end 
                hit_ballon = true 
            end
        end
        shoot:remove_dart(shoot:get_current_ammo())
        hit_ballon = false
    end
end

-- get the state
function game:get_state()
    return self.state
end

-- set the state
function game:set_state(new_state)
    self.state = new_state
    game:reset_time()
end 

-- get health
function game:add_health(val)
    if val then self.health = self.health + val end
end

-- add score
function game:add_score(score)
    if score then self.score = self.score + score end 
end 

-- add score
function game:get_score(score)
    return self.score
end 

-- save score
function game:save_score(name)
    local file, err = io.open("scores.txt", 'a')
    local score_ = name .. "#" .. self.score .. "\n"
    if file then 
        file:write(score_)
        file:close()
    else
        print("error: ", err)
    end 
end 