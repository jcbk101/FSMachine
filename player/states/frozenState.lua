local M = {}

-- Local variables
M.is_exiting = false


-----------------------------------
-- Initialize state
-----------------------------------
M.init = function(self, parent)
	self.is_exiting = false
	self.frozen_timer = 6
	parent.throw_time = nil
	msg.post("#status_effect", "enable")
	msg.post("#counter", "enable")		
	msg.post("#status", "enable")
	label.set_text("#status", "FROZEN")

	sprite.play_flipbook("#status_effect", "freeze")
	go.set("#sprite", "playback_rate", 0)
	-----
	self.tick = 1 / (self.frozen_timer * 60)
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
		self.frozen_timer = self.frozen_timer - dt
		if self.frozen_timer <= 0 then
			self.frozen_timer = nil
			parent.frozen = nil
			self:changeState(parent, "idle")
			go.set("#sprite", "playback_rate", 1)
			----------------------------------
			sprite.play_flipbook("#status_effect", "ice_break", 
			function(self, message_id, message)
				if message_id == hash("animation_done") then
					msg.post("#status_effect", "disable")
					msg.post("#status", "disable")					
					msg.post("#counter", "disable")
				end
			end)
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