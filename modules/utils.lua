local utils =  {}

-------------------------------
--
---------------------------------
function utils.getAnimationFrames(sprite_id, anim)

	local path = go.get(sprite_id, "image")
	local ts_info = resource.get_atlas(path)

	for i = 1, #ts_info.animations do
		if hash(ts_info.animations[i].id) == anim then
			local frames, fps = go.get(sprite_id, "frame_count"), ts_info.animations[i].fps
			local time = (1.0 / fps) * frames
			return { frames = frames, fps = fps, time = time }
		end
	end

	-- Default FPS
	local frames, fps = go.get(sprite_id, "frame_count"), ts_info.animations[1].fps
	local time = (1.0 / 10.) * frames
	return { frames = frames, fps = fps, time = time }
end

-------------------------------
--
-------------------------------
function utils.Perpendicular( vector, CW ) -- Default: Counter clock wise, CW == true and Clock wise
	if CW then
		return vmath.vector3(vector.y, -vector.x, vector.z)	
	else
		return vmath.vector3(-vector.y, vector.x, vector.z)	
	end
end

-------------------------------
--
-------------------------------
function utils.Angle( from, to )
	local dot = vmath.dot( vmath.normalize(from), vmath.normalize(to))
	local acos = math.acos( dot )
	local deg = math.deg(acos)

	return deg
end

return utils