local M = {}

-- Local variables
M.is_exiting = nil

-----------------------------------
-- Initialize state
-----------------------------------
M.init = function(self, parent)
	sprite.play_flipbook("#sprite", "wall_jump")
	self.is_exiting = nil
	parent.velocity.x = 0
	parent.velocity.y = 0
	parent.is_wallSliding = true
end

-----------------------------------
-- Exit state
-----------------------------------
M.exit = function( self, parent )
	self.is_exiting = true
	parent.is_wallSliding = nil
end

-----------------------------------
-- Process input
-----------------------------------
M.input = function(self, parent, action_id, action)
	if not self.is_exiting then

		if (action_id == hash("left") or action_id == hash("right")) and (action.value and action.value > 0) then
			-- Player is pressing a direction. If not with a 'JUMP' press, then fall off
			if action_id == hash("jump") and (action and action.pressed) then
				-- Leap in the direction away from the wall ALWAYS
				parent.velocity.x = self.move_speed * parent.wall_side
				self:changeState( parent, "jump" )
				return
			else
				-- Just fall off
				--parent.velocity.x = (self.move_speed * .25) * -parent.wall_side				
				print("WALL: fall")
				self:changeState( parent, "fall" )
				return
			end
			-- If just jump is pressed, then hop off of the wall
		elseif action_id == hash("jump") and (action and action.pressed) then
			self:changeState(parent, "jump", { wallJump = true } )
		end		
	end		
end


-----------------------------------
-- Fixed update function
-----------------------------------
M.fixed_update = function(self, parent, dt)
	if self.is_exiting then return end

	local pos = go.get_position()

	-- Slide speed: slow but steady
	pos.y = pos.y + ((self.gravity * .05) * dt)

	-----------------------------------------
	go.set_position(pos)

	-- If player slid to the ground then exit this state
	--	parent.wall_contact = false		
	--self.CheckForWall(parent, pos)
	--if not parent.wall_contact then
	if not parent.wall_contact then
		self:changeState( parent, "fall" )
		return
	end

	if parent.ground_contact == true then
		parent.velocity.y = 0
		self:changeState( parent, "land" )
		return
	end				
	parent.ground_contact = false
	parent.wall_contact = false	
	parent.correction.x, parent.correction.y, parent.correction.z = 0, 0, 0			
end

return M