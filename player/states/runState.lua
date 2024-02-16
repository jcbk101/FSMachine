local M = {}

-- Local variables
M.is_exiting = false
M.falls = 0

-----------------------------------
-- Initialize state
-----------------------------------
M.init = function(self, parent)
	self.is_exiting = false
	self.falls = 0
	self.throw_time = nil
	parent.throw_time = nil
	sprite.play_flipbook("#sprite", "run")
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
	if not self.is_exiting then			
		if action_id == hash("jump") and (action and action.pressed) and parent.states.jump:CanJump() then
			self:changeState(parent, "jump")
			parent.isOnSlope = nil
			return
		elseif action_id == hash("throw") and (action and action.pressed) then
			--self:changeState(parent, "throw")				
			self.throw_time = self.getAnimationFrames("#sprite", "throw_run").time
			sprite.play_flipbook("#sprite", "throw_run")
		end			
		if (action_id == hash("left") or action_id == hash("right")) then
			if (action.value and action.value == 0) then
				physics.set_listener(nil)
				self:changeState(parent, "idle")
			else
				local anim = go.get("#sprite", "animation")

				if parent.canPush and anim ~= hash("push") then
					sprite.play_flipbook("#sprite", "push")
				elseif not parent.canPush and anim ~= hash("run") and anim ~= hash("throw_run") then
					sprite.play_flipbook("#sprite", "run")
				end
				--
				self.BasicMove(parent, action_id, action, air_acceleration_factor)
			end
		end			
	end			
end


-----------------------------------
-- Fixed update function
-----------------------------------
M.fixed_update = function(self, parent, dt)
	if not self.is_exiting then		
		local pos = go.get_position()

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

		-- Handle the throw animation
		if self.throw_time then
			self.throw_time = self.throw_time - dt
			if self.throw_time <= 0 then
				self.throw_time = nil
				sprite.play_flipbook("#sprite", "run")
			end
		end

		----------------------------------------			
		if not parent.ground_contact then
			-- Done to prevent false 'FALL'  and twitching
			if self.falls > 5 then 
				parent.throw_time = self.throw_time
				self.throw_time = nil
				sprite.play_flipbook("#sprite", "fall")
				self:changeState(parent, "air")
				return
			else
				self.falls = self.falls + 1
			end
		else
			self.falls = 0
		end		

		--------------------------------
		go.set_position(pos)
		parent.ground_contact = false
		parent.wall_contact = false
		parent.correction.x, parent.correction.y, parent.correction.z = 0, 0, 0			
	end	
end

return M