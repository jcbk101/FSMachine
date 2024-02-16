local M = {}

-- Local variables
M.is_exiting = false

-----------------------------------
-- Initialize state
-----------------------------------
M.init = function(self, parent)
	self.is_exiting = false
	self.stun_timer = 6
	parent.throw_time = nil
	sprite.play_flipbook("#sprite", "stun")
	label.set_text("#status", "PARALYZED")
	msg.post("#counter", "enable")
	msg.post("#status", "enable")
	--
	self.tick = 1 / (self.stun_timer * 60)
	self.counter = 1
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

		-- Timer count down until confusion is over
		self.counter = self.counter - self.tick
		go.set("#counter", "value", vmath.vector4(self.counter,0,0,0) )
		--						
		self.stun_timer = self.stun_timer - dt
		if self.stun_timer <= 0 then
			self.stun_timer = nil
			parent.confused = nil
			msg.post("#counter", "disable")
			msg.post("#status", "disable")
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