local M = {}

-- Local variables
M.is_exiting = false

-----------------------------------
-- Initialize state
-----------------------------------
M.init = function(self, parent)
	self.is_exiting = false
	parent.states.jump.jumpAmount = 2
	parent.wall_contact = nil
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
		local anim = go.get("#sprite", "animation")

		if parent.velocity.x ~= 0 then
			if anim == hash("crouch") then
				self:changeState(parent, "crawl")
			else
				self:changeState(parent, "run")
			end
		else
			-- Player is touching earth. Switch state to LANDING
			if anim == hash("crouch") then
				self:changeState(parent, "crouch")
			else
				self:changeState(parent, "idle")
			end
		end
	end	
end

return M