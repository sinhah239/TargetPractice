speed_ballon = ballon:new(
    {
        scale = 4,
        x = (gameWidth / 2),
        y = (gameHeight * 1.5),
        speed = 100,
        sprite_path = 'assets/sprites/speed_ballon.png', 
        sound_path = 'assets/sounds/ballon_pop.wav',
        value = 4,
        color = "yellow",
        num_frames = 24,
        is_speed_ballon = true
    })

function speed_ballon:new(new)
    new = new or {}
    setmetatable(new, self)
    self.__index = self 
    return new
end 

function speed_ballon:init() 
    self.x = math.random(gameWidth * 0.2, gameWidth * 0.8)

    self.sprite = love.graphics.newImage(self.sprite_path)
    self.grid = anim8.newGrid(32, 32, self.sprite:getWidth(), self.sprite:getHeight())
    self.animation = anim8.newAnimation(self.grid('1-24', 1), 0.05)

    self.effect = {}
    self.effect.sprite = love.graphics.newImage('assets/sprites/speed_effect.png')
    self.effect.grid = anim8.newGrid(32, 32, self.effect.sprite:getWidth(), self.effect.sprite:getHeight())
    self.effect.animation = anim8.newAnimation(self.effect.grid('1-16', 1), 0.1)
    self.effect.rad = 3
    local e_x, e_y = speed_ballon:calc_displace(
        self.sprite:getHeight() * self.scale, 
        self.sprite:getHeight() * self.scale,
        self.effect.sprite:getHeight() * self.scale * self.effect.rad, 
        self.effect.sprite:getHeight() * self.scale * self.effect.rad)

    self.effect.x = self.x - e_x 
    self.effect.y = self.y - e_y
    self.sound = love.audio.newSource(self.sound_path, "static")
    self.sound:setVolume(0.05)
end

function speed_ballon:update(dt) 
    self.y = self.y - self.speed * dt
    self.animation:update(dt)
    self.effect.animation:update(dt)

    local e_x, e_y = speed_ballon:calc_displace(
        self.sprite:getHeight() * self.scale, 
        self.sprite:getHeight() * self.scale,
        self.effect.sprite:getHeight() * self.scale * self.effect.rad, 
        self.effect.sprite:getHeight() * self.scale * self.effect.rad)

    self.effect.x = self.x - e_x 
    self.effect.y = self.y - e_y
    self:apply_speed() 
end 

function speed_ballon:draw()
    self.effect.animation:draw(self.effect.sprite, self.effect.x, self.effect.y, nil, self.scale * self.effect.rad, self.scale * self.effect.rad)
    self.animation:draw(self.sprite, self.x, self.y, nil, self.scale, self.scale)
end

function speed_ballon:calc_displace(s_width, s_height, l_width, l_height)
    local x_disp = (l_width - s_width) / 2 
    local y_disp = (l_height - s_height) / 2
    return x_disp, y_disp
end 

function speed_ballon:get_ballons(ballons_)
    self.ballons = ballons_
end 

function speed_ballon:apply_speed() 
    local x = self.x + self.sprite:getHeight() * self.scale / 2
    local y = self.y + self.sprite:getHeight() * self.scale / 2
    local rad = self.effect.sprite:getHeight() * self.scale * self.effect.rad / 2
    for i,v in ipairs(self.ballons.list) do  
        if not v.is_speed_ballon then
            local center_x, center_y, radius
            local width = v.sprite:getWidth() * v.scale
            if v.num_frames then 
                width = width / v.num_frames
            end 
            center_x = v.x + (width) / 2
            center_y = v.y + (width) / 2.5

            if center_x < x + rad and center_x > x - rad and center_y < y + rad and center_y > y - rad then 
               v:get_speed_boost()
            end
        end 
    end 
end 