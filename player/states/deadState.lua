local M = {}

-- Local variables
M.is_exiting = false

-----------------------------------
-- Initialize state
-----------------------------------
M.init = function(self, parent)
	self.is_exiting = false
	parent.velocity.x = 0
	--
	msg.post("#status_effect", "disable")
	msg.post("#counter", "disable")
	--
	self.time = self.getAnimationFrames("#sprite", "die").time + 1
	sprite.play_flipbook("#sprite", "die")
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
		local pos = go.get_position()

		-- Timer count down until death is over
		self.time = self.time - dt
		if self.time <= 0 then
			self.time = nil
			-- Respawn
			go.set_position(parent.origin)
			parent.invulnerable = 50
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