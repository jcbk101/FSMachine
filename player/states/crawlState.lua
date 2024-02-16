local M = {}

-- Local variables
M.is_exiting = false

-----------------------------------
-- Initialize state
-----------------------------------
M.init = function(self, parent)
	self.is_exiting = false
	self.falls = 0
	sprite.play_flipbook("#sprite", "crawl")
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
		-- DEBUG ONLY, THIS 'IF'
		if action_id == hash("up") and action.pressed then 
			self:changeState(parent, "idle")
		elseif (action_id == hash("left") or action_id == hash("right")) then
			if (action.value and action.value == 0) then
				self:changeState(parent, "crouch_idle")
			else
				self.BasicMove(parent, action_id, action, 0.35)
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

		if not parent.ground_contact then
			-- Done to prevent false 'FALL'  and twitching
			if self.falls > 5 then 
				sprite.play_flipbook("#sprite", "crouch")
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