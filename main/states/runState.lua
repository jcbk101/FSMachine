local utils = require("modules.utils")
local M = {}


---------------------------------
--
---------------------------------
local function SlopeCheck(self, position)

	local scale = go.get("#sprite", "scale")
	local slopeDistance = max_speed * 0.25
	local size = vmath.mul_per_elem(self.sprSize, scale)

	local from = vmath.vector3(position.x, position.y, position.z)	
	local to = vmath.vector3(from.x + (self.direction * 32), (from.y - size.y * .5) - slopeDistance , from.z)	
	local toC = vmath.vector3(from.x, (from.y - size.y * .5) - slopeDistance , from.z)		
	local hit = physics.raycast(from, to, { hash("ground") })
	local hitC = physics.raycast(from, toC, { hash("ground") })
	local ang = 0

	if hit and hitC then
		if vmath.length(from - hit.position) > vmath.length(from - hitC.position) then
			hit = nil
			hit = hitC
		end
	end

	-- No snapping if not a ground hit
	self.slopeY = nil

	--msg.post("@render:", "draw_line", { start_point = to, end_point = from, color = vmath.vector4(1, 0, 1, 1) })	
	--msg.post("@render:", "draw_line", { start_point = toC, end_point = from, color = vmath.vector4(0, 1, 1, 1) })		

	if hit then
		local sign = (hit.normal.x > 0 and -1 or 1)
		self.slopeNormalPerp = Perpendicular(hit.normal) -- Counter clock wise
		ang = Angle( hit.normal, vmath.vector3(0, 1, 0))
		-- Rotate the object according to the slope
		--		go.set(".", "euler.z", ang * sign)
		self.slopeY = hit.position.y + size.y *.5
		--msg.post("@render:", "draw_line", { start_point = hit.position, end_point = from, color = vmath.vector4(1, 1, 1, 1) })			
	end	

	if ang == 0 then
		self.isOnSlope = nil
	else
		if ang > ANGLE_THRESHOLD + 1 then
			self.slopeY = nil
			self.isOnSlope = nil
		else
			self.isOnSlope = true
		end
	end
end

------------------------------------
--
------------------------------------
function M.new()

	-- Local variables
	local run = {
		is_exiting = false
	}

	-----------------------------------------------
	run.init = function(self, parent)
		self.is_exiting = false
		self.falls = 0
		sprite.play_flipbook("#sprite", "run")
	end

	-----------------------------------------------
	run.exit = function(self, parent)
		self.is_exiting = true
	end

	-----------------------------------------------
	run.input = function(self, parent, action_id, action)
		if not self.is_exiting then			
			if action_id == hash("jump") and (action and action.pressed) and parent.states.jump:CanJump() then
				self:changeState(parent, "jump")
				parent.isOnSlope = nil
				return
			elseif (action_id == hash("left") or action_id == hash("right")) then
				if (action.value and action.value == 0) then
					self:changeState(parent, "idle")
				else
					if action_id == hash("left") and action.value and action.value > 0 then
						sprite.set_hflip("#sprite", true)
						parent.velocity.x = -max_speed
						parent.direction = -1
					elseif action_id == hash("right") and action.value and action.value > 0 then
						sprite.set_hflip("#sprite", false)
						parent.velocity.x = max_speed
						parent.direction = 1
					end					
				end
			end
		end			
	end

	-----------------------------------------------
	run.fixed_update = function(self, parent, dt)
		if not self.is_exiting then		
			local pos = go.get_position()

			SlopeCheck(parent, pos)

			if parent.ground_contact == true then
				parent.velocity.y = 0
			end		

			if parent.isOnSlope then
				parent.ground_contact = true
				parent.velocity.y = 0
				pos.y = parent.slopeY				
				pos.x = (pos.x + parent.velocity.x * dt)
			else
				if parent.slopeY then
					parent.ground_contact = true
					parent.velocity.y = 0
					pos.y = parent.slopeY					
					pos.x = (pos.x + parent.velocity.x * dt)					
				else
					parent.velocity.y = parent.velocity.y + (gravity * dt)
					if parent.velocity.y < -1250.0 then 
						parent.velocity.y = -1250.0
					end
					pos = (pos + parent.velocity * dt)
				end
			end

			-- Reset X after moving so the player does not stick to a wall
			if parent.wall_contact then
				parent.velocity.x = 0
			end

			if not parent.ground_contact then
				sprite.play_flipbook("#sprite", "fall")
				self:changeState(parent, "air")
				return
			end		

			--------------------------------
			--			pos = (pos + parent.velocity * dt)

			------------------
			go.set_position(pos)
			parent.ground_contact = false
			parent.wall_contact = false
			parent.correction.x, parent.correction.y, parent.correction.z = 0, 0, 0			
		end
	end

	return run
end

return M