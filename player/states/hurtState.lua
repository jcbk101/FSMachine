local M = {}

-- Local variables
M.is_exiting = false

-----------------------------------
-- Initialize state
-----------------------------------
M.init = function(self, parent, options)
	local options = options or { force = 2, direction = -parent.direction }
	self.is_exiting = false
	parent.throw_time = nil
	parent.velocity.x = 0
	self.time = self.getAnimationFrames("#sprite", "hurt").time
	sprite.play_flipbook("#sprite", "hurt")
	-- Do knockback
	self.knockback = vmath.vector3(max_speed * options.force * options.direction, 0, 0)
	self.knockback_timer = 0.1
end

-----------------------------------
-- Exit state
-----------------------------------
M.exit = function(self, parent)
	self.is_exiting = true
end


-----------------------------------
-- Fixed update function
-----------------------------------
M.fixed_update = function(self, parent, dt)
	if not self.is_exiting then		
		local pos = go.get_position() + (self.knockback * dt)

		-- Timer count down until knockback is over
		if self.knockback_timer then
			self.knockback_timer = self.knockback_timer - dt
			if self.knockback_timer <= 0 then
				self.knockback.x = 0
				self.knockback.y = 0				
				self.knockback_timer = nil
			end
		end

		-- Timer count down until knockback is over
		self.time = self.time - dt
		if self.time <= 0 then
			self.knockback_timer = nil
			self.time = nil
			self:changeState(parent, "idle")
			return
		end

		-- Handle slope contact and walking
		self.SlopeCheck(parent, pos)

		if parent.ground_contact == true then
			parent.velocity.y = 0
		end		

		pos = self.ApplyGravity(parent, pos, dt)

		-- Reset X after moving so the player does not stick to a wall
		if parent.wall_contact then
			parent.velocity.x = 0
		end

		--------------------------------
		go.set_position(pos)
		parent.ground_contact = false
		parent.wall_contact = false
		parent.correction.x, parent.correction.y, parent.correction.z = 0, 0, 0			
	end		
end

return M