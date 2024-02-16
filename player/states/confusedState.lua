local M = {}

-- Local variables
M.is_exiting = false

-----------------------------------
-- Initialize state
-----------------------------------
M.init = function(self, parent)
	self.is_exiting = false
	self.confused_timer = 6
	math.randomseed(os.clock())

	parent.throw_time = nil
	parent.velocity.x = math.random()

	msg.post("#counter", "enable")
	msg.post("#status", "enable")
	label.set_text("#status", "CONFUSED")
	--
	self.tick = 1 / (self.confused_timer * 60)
	self.counter = 1
end

-----------------------------------
-- Exit state
-----------------------------------
M.exit = function(self, parent)
	self.is_exiting = true
end

-----------------------------------
-- Process input
-----------------------------------
M.input = function(self, parent, action_id, action)
	-- Confused player: Mix up the controls
	if not self.is_exiting then			
		if (action_id == hash("left") or action_id == hash("right")) then
			local anim = go.get("#sprite", "animation")

			if parent.canPush and anim ~= hash("push") then
				sprite.play_flipbook("#sprite", "push")
			elseif not parent.canPush and anim ~= hash("run") and anim ~= hash("throw_run") then
				sprite.play_flipbook("#sprite", "run")
			end
			--
			self.BasicMove(parent, action_id, action, air_acceleration_factor, true)
			--end
		end			
	end			
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
		self.confused_timer = self.confused_timer - dt
		if self.confused_timer <= 0 then
			self.confused_timer = nil
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