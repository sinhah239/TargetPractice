pointer = {}

function pointer:new(new) 
    new = new or {}
    setmetatable(new, self)
    self.__index = self 
    return new
end 

-- initalize pointer
function pointer:init(debug) 
    new_pointer = pointer:new()
    new_pointer.x = 0 
    new_pointer.y = 0
    new_pointer.scale = 3
    new_pointer.sprite_size = 16
    new_pointer.sprite = love.graphics.newImage("assets/sprites/pointer_scaled.png")
    new_pointer.debug = debug
    new_pointer.shooting = false
    new_pointer.isEmpty = false
    new_pointer.sounds = {}
    new_pointer.sounds.hit = love.audio.newSource("assets/sounds/dart_throw.mp3", "static")
    new_pointer.sounds.hit:setPitch(1.5)
    new_pointer.sounds.hit:setVolume(0.1)
    new_pointer.sounds.select = love.audio.newSource("assets/sounds/select.mp3", "static")
    new_pointer.sounds.select:setVolume(0.5)
    love.mouse.setVisible(false)
    return new_pointer
end

-- update pointer 
function pointer:update(dt, i, num_pointers)
    -- set the custom cursor to mouse position
    local dist_mult = 0.3
    local mouse_x, mouse_y = love.mouse.getPosition()
    if mouse_x > gameWidth then 
        mouse_x = gameWidth 
    end 
    if mouse_y > gameHeight then 
        mouse_y = gameHeight 
    end
    local total_width = num_pointers * self.sprite:getWidth() * self.scale + (num_pointers - 1) * self.sprite:getWidth() * self.scale * dist_mult
    local start = mouse_x - total_width / 2
    self.x = start + (i - 1) * self.sprite:getWidth() * self.scale + (i - 1) * self.sprite:getWidth() * self.scale * dist_mult
    self.y = mouse_y - self.sprite_size * self.scale / 2 
    if num_pointers > 1 and i ~= (math.ceil(num_pointers / 2)) then 
        self.sprite = love.graphics.newImage("assets/sprites/pointer_multi.png")
    end 
end 

-- draw pointer
function pointer:draw(dt)
    love.graphics.draw(self.sprite, self.x, self.y, 0, self.scale)
end 

-- calculates pointer distance to center and returns true if dist is within radius, returns false otherwise
function pointer:check_shot(ballon, ammo)
    local center_x, center_y, radius
    local width = ballon.sprite:getWidth() * ballon.scale
    if ballon.num_frames then 
        width = width / ballon.num_frames
    end 
    center_x = ballon.x + (width) / 2
    center_y = ballon.y + (width) / 2.5
    radius = (width) * 0.4
    
    local x, y
    x = self.x + self.sprite_size * self.scale / 2
    y = self.y + self.sprite_size * self.scale / 2
    dist_x = x - center_x 
    dist_y = y - center_y
    dist_to_center = math.sqrt(dist_x * dist_x + dist_y * dist_y) 
    if dist_to_center < radius and ammo > 0 then
        return true
    end
    return false
end 

-- plays a sound 
function pointer:play_sound(shoot, sound)
    if not sound then 
        if shoot.current_ammo >= 0 then 
            self.sounds.hit:play()
        end
    else 
        self.sounds[sound]:play()
    end 
end 

-- signal that the player is shooting
function pointer:set_shooting(is_shooting)
    self.shooting = is_shooting 
end

function pointer:get_pos()
    return self.x + self.sprite_size * self.scale / 2, self.y + self.sprite_size * self.scale / 2
end