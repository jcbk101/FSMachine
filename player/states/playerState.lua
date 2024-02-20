local utils = require("modules.utils")

local M = {}

M.gravity = -2200
M.jump_takeoff_speed = 1100
M.max_speed = 500
M.air_acceleration_factor = 0.8
M.ANGLE_THRESHOLD = 46
M.NORMAL_THRESHOLD = 0.7

---------------------------------
--
---------------------------------
function M.SlopeCheck(self, position)

	local scale = go.get("#sprite", "scale")
	local slopeDistance = M.max_speed * 0.1
	local size = vmath.mul_per_elem(self.sprSize, scale)

	local from = vmath.vector3(position.x, position.y, position.z)	
	local to = vmath.vector3(from.x + (self.direction * 32), (from.y - size.y * .5) - slopeDistance , from.z)	
	local toC = vmath.vector3(from.x, (from.y - size.y * .5) - slopeDistance , from.z)		
	local hit = physics.raycast(from, to, { hash("ground") })
	local hitC = physics.raycast(from, toC, { hash("ground") })
	local ang = 0

	-- Start off flat
	self.slopeAngle = 0

	if hit and hitC then
		if vmath.length(from - hit.position) > vmath.length(from - hitC.position) then
			hit = nil
			hit = hitC
		end
	end

	-- No snapping if not a ground hit
	self.slopeY = nil

	--	msg.post("@render:", "draw_line", { start_point = to, end_point = from, color = vmath.vector4(1, 0, 1, 1) })	
	--msg.post("@render:", "draw_line", { start_point = toC, end_point = from, color = vmath.vector4(0, 1, 1, 1) })		

	if hit then
		local sign = (hit.normal.x > 0 and -1 or 1)
		self.slopeNormalPerp = utils.Perpendicular(hit.normal) -- Counter clock wise
		ang = utils.Angle( hit.normal, vmath.vector3(0, 1, 0))
		-- Rotate the object according to the slope
		--		go.set(".", "euler.z", ang * sign)
		self.slopeY = hit.position.y + size.y *.5
		--msg.post("@render:", "draw_line", { start_point = hit.position, end_point = from, color = vmath.vector4(1, 1, 1, 1) })			
	end	

	if ang == 0 then
		self.isOnSlope = nil
	else
		if ang > M.ANGLE_THRESHOLD then
			self.slopeY = nil
			self.isOnSlope = nil
		else
			self.isOnSlope = true
		end
	end
end


-- ---------------------------------
-- --
-- ---------------------------------
-- function M.CheckForWall(self, position)
-- 
-- 	local from = vmath.vector3(position.x, position.y, position.z)	
-- 	local to = vmath.vector3(from.x + (self.direction * 32), from.y, from.z)	
-- 	local hit = physics.raycast(from, to, { hash("ground") })
-- 
-- 	msg.post("@render:", "draw_line", { start_point = to, end_point = from, color = vmath.vector4(1, 0, 1, 1) })	
-- 
-- 	print("WALL: ", from.x, to.x, (hit and hit.normal or "nil"))
-- 	if hit then
-- 		msg.post("@render:", "draw_line", { start_point = hit.position, end_point = from, color = vmath.vector4(1, 1, 1, 1) })
-- 		if math.abs(hit.normal.x) == 1 then
-- 			self.wall_contact = true
-- 		end
-- 	else
-- 		--self.wall_contact = nil
-- 	end	
-- 
-- end
-- 

---------------------------------
-- Common movement
---------------------------------
function M.BasicMove(parent, action_id, action, speedAdjust, is_confused )

	-- Normally for speed adjustment when crawling or airbourne
	if not speedAdjust then speedAdjust = 1 end

	if is_confused then
		if action_id == hash("right") and action.value and action.value > 0 then
			sprite.set_hflip("#sprite", true)
			physics.set_hflip("#is_push", true)
			physics.set_hflip("#is_trigger", true)		
			parent.velocity.x = -M.max_speed * speedAdjust
			parent.direction = -1
			return true
		elseif action_id == hash("left") and action.value and action.value > 0 then
			sprite.set_hflip("#sprite", false)
			physics.set_hflip("#is_push", false)
			physics.set_hflip("#is_trigger", false)
			parent.velocity.x = M.max_speed * speedAdjust
			parent.direction = 1
			return true
		end		
	else
		if action_id == hash("left") and action.value and action.value > 0 then
			sprite.set_hflip("#sprite", true)
			physics.set_hflip("#is_push", true)
			physics.set_hflip("#is_trigger", true)		
			parent.velocity.x = -M.max_speed * speedAdjust
			parent.direction = -1
			return true
		elseif action_id == hash("right") and action.value and action.value > 0 then
			sprite.set_hflip("#sprite", false)
			physics.set_hflip("#is_push", false)
			physics.set_hflip("#is_trigger", false)
			parent.velocity.x = M.max_speed * speedAdjust
			parent.direction = 1
			return true
		end
	end

	return false
end


---------------------------------
-- Common gravity for states
-- Thatsupport slopes
---------------------------------
function M.ApplyGravity(parent, pos, dt)

	if parent.isOnSlope then
		parent.ground_contact = true
		parent.velocity.y = 0
		pos.y = parent.slopeY or pos.y
		pos.x = (pos.x + parent.velocity.x * dt)
	else
		if parent.slopeY then
			parent.ground_contact = true
			parent.velocity.y = 0
			pos.y = parent.slopeY					
			pos.x = (pos.x + parent.velocity.x * dt)					
		else
			parent.velocity.y = parent.velocity.y + (M.gravity * dt)
			if parent.velocity.y < -1250.0 then 
				parent.velocity.y = -1250.0
			end
			-- Used to keep the character from being stuck on wall collider tiles
			if parent.wall_contact then
				parent.velocity.x = parent.velocity.x * .5
			end

			pos = (pos + parent.velocity * dt)
		end
	end	

	return pos
end

-------------------------------
--
---------------------------------
function M.getAnimationFrames(sprite_id, anim)

	local path = go.get(sprite_id, "image")
	local ts_info = resource.get_atlas(path)

	for i = 1, #ts_info.animations do
		if hash(ts_info.animations[i].id) == hash(anim) then
			--local frames, fps = go.get(sprite_id, "frame_count"), ts_info.animations[i].fps
			local frames = ts_info.animations[i].frame_end - ts_info.animations[i].frame_start
			local fps = ts_info.animations[i].fps
			local time = (1.0 / fps) * frames
			return { frames = frames, fps = fps, time = time }
		end
	end

	-- Default FPS
	local frames, fps = go.get(sprite_id, "frame_count"), ts_info.animations[1].fps
	local time = (1.0 / 10.) * frames
	return { frames = frames, fps = fps, time = time }
end

return M
