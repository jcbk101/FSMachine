local M = {}

-- Local variables
M.is_exiting = false

-----------------------------------
-- Initialize state
-----------------------------------
M.init = function(self, parent)
	self.is_exiting = false
	parent.isOnSlope = nil
	parent.slopeY = nil
	--
	self.throw_time = parent.throw_time
	parent.throw_time = nil
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
		if not self.BasicMove(parent, action_id, action, air_acceleration_factor) then
			parent.velocity.x = 0
		end

		-- Test for air jump or abort jump
		if action_id == hash("jump") then
			if action and action.released then -- Abort the jump
				if parent.velocity.y > 0 then
					parent.velocity.y = parent.velocity.y * 0.5
				end
			elseif (action and action.pressed) and parent.states.jump:CanJump() then
				parent.states.jump.jumpAmount = 1 -- Only allow air jump
				self:changeState(parent, "jump")
			end
			-----------------------------------------
		elseif action_id == hash("throw") and (action and action.pressed) then
			--self:changeState(parent, "throw")
			self.throw_time = self.getAnimationFrames("#sprite", "throw").time
			sprite.play_flipbook("#sprite", "throw")				
			return
		end			
	end
end


-----------------------------------
-- Fixed update function
-----------------------------------
M.fixed_update = function(self, parent, dt)
	if not self.is_exiting then		
		local pos = go.get_position()

		if not parent.ground_contact then
			self.isOnSlope = nil
			self.slopeY = nil
			pos = self.ApplyGravity(parent, pos, dt)

			-- Handle the throw animation
			if self.throw_time then
				self.throw_time = self.throw_time - dt
				if self.throw_time <= 0 then
					self.throw_time = nil
					sprite.play_flipbook("#sprite", "fall")
				end
			end

			-- Go into a fall if the velocity.y < 0
			if parent.velocity.y < 0 then
				parent.throw_time = self.throw_time
				self.throw_time = nil
				self:changeState(parent, "fall")
				return
			end

			if parent.wall_contact then
				parent.velocity.x = 0
			end

			--------------------------------------
			go.set_position(pos)
			parent.wall_cntact = false
			parent.correction.x, parent.correction.y, parent.correction.z = 0, 0, 0
		else
			parent.throw_time = self.throw_time
			self.throw_time = nil
			self:changeState(parent, "land")
		end
	end	
end

return M