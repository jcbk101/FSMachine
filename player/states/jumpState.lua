local M = {}

-- Local variables
M.jumpAmount = 2

-----------------------------------
-- Initialize state
-----------------------------------
M.init = function(self, parent)
	if self.jumpAmount > 0 then
		parent.velocity.y = self.jump_takeoff_speed * (self.jumpAmount == 2 and 1 or 0.75)
		if not parent.throw_time then
			sprite.play_flipbook("#sprite", "jump" .. self.jumpAmount)
		end
		-------------------------------------
		self.jumpAmount = self.jumpAmount - 1
		parent.ground_contact = false
		self:changeState(parent, "air" )
	end
end

-----------------------------------
-- Condition test
-----------------------------------
M.CanJump = function(self)
	return (self.jumpAmount > 0 and true or false)
end


return M