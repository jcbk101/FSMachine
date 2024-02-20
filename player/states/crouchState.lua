local M = {}

-- Local variables
M.is_exiting = false
M.falls = 0

-----------------------------------
-- Initialize state
-----------------------------------
M.init = function(self, parent)
	self.is_exiting = false
	-- Change to Idle ONLY is not already idling
	if go.get("#sprite", "animation") ~= hash("crouch") then
		sprite.play_flipbook("#sprite", "crouch")
	end
	parent.states.jump.jumpAmount = 2
	parent.velocity.y = 0
	parent.velocity.x =  0
	parent.isOnSlope = nil
	self.throw_time = parent.throw_time
	parent.throw_time = nil
	self.falls = 0
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
		if (action_id == hash("left") or action_id == hash("right")) and (action.value and action.value > 0) then
			self:changeState(parent, "crawl")
		elseif action_id == hash("up") and (action and action.pressed) then
			self:changeState(parent, "idle")
		end					
	end		
end

-----------------------------------
-- Update function
-----------------------------------
M.update = function(self, parent, dt)
-- Do not have to declare
end


-----------------------------------
-- Fixed update function
-----------------------------------
M.fixed_update = function(self, parent, dt)

	local pos = go.get_position()

	-- Handle slope contact
	self.SlopeCheck(parent, pos)
	pos = self.ApplyGravity(parent, pos, dt)

	-----------------------------------------
	if not parent.ground_contact then
		parent.throw_time = self.throw_time
		self.throw_time = nil
		self:changeState(parent, "fall")
		return
	end		

	-- Handle the throw animation for idling
	if self.throw_time then
		self.throw_time = self.throw_time - dt
		if self.throw_time <= 0 then
			self.throw_time = nil
			sprite.play_flipbook("#sprite", "idle")
		end
	end
	------------------------------------
	go.set_position(pos)
	if parent.ground_contact == true then
		parent.velocity.y = 0
	end				
	parent.ground_contact = false
	parent.correction.x, parent.correction.y, parent.correction.z = 0, 0, 0			
end

return M