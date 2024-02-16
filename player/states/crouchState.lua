local M = {}

-- Local variables
M.is_exiting = false
M.falls = 0

-----------------------------------
-- Initialize state
-----------------------------------
M.init = function(self, parent)
	self.is_exiting = false
	sprite.play_flipbook("#sprite", "crouch")
	if go.get("#sprite", "animation") ~= hash("crouch") then
		sprite.play_flipbook("#sprite", "crouch")
	end
	parent.velocity.x = 0
	parent.isOnSlope = nil
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
		-- DEBUG ONLY, THIS 'IF'
		if action_id == hash("up") and action.pressed then 
			self:changeState(parent, "idle")

		elseif (action_id == hash("left") or action_id == hash("right")) and (action.value and action.value > 0) then
			self:changeState(parent, "crawl")
		end
	end		
end


-----------------------------------
-- Fixed update function
-----------------------------------
M.fixed_update = function(self,parent,dt)

	local pos = go.get_position()

	-- Handle slope contact
	self.SlopeCheck(parent, pos)
	pos = self.ApplyGravity(parent, pos, dt)

	-----------------------------------------
	if not parent.ground_contact then
		-- Switch the animation here. 
		-- Calling from from 'AIR STATE' can disrupt a jump animation
		sprite.play_flipbook("#sprite", "fall")
		self:changeState(parent, "air")
		return
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