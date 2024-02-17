# Defold 2D Platformer Finite State Machine

In this project you will find an example of a simple Finite State Machine implementation for the <a href="https://www.defold.com">Defold game engine</a>, using Lua, without any plugins.

You will find FSM Controller under <a href="modules/fsm_engine.lua">`/modules/fsm_engine.lua`</a>. Example code is in <a href="main/main.script">`/main/main.script`</a>.

A video showing this example can be found at: 


## What can the State Machine do?

### Example: Script file
<a href="main/main.script">`/main/main.script`</a>
####
To utilize the FSM, it must first be inluded in the main script file so it and its functions can be accessible.
```lua
local fsm = require("modules.fsm_engine")
```

In the main script file, all states are created using Module references. IE: 

```lua
-- Super state: Contains shared functions
local playerState = require("player.states.playerState") -- State that contains shared functions
-- Sub state
local landState = require("player.states.landState")
```

Each lua module will have code structured as below...

```lua
local M = {}

-- Local variables
M.is_exiting = false

-----------------------------------
-- Initialize state
-----------------------------------
M.init = function(self, parent)
	self.is_exiting = false
	parent.states.jump.jumpAmount = 2
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
```
With the state(s) defined within the scope of the current script, the FSM is initialized like so:

```lua
------------------------------------
-- Init code 
------------------------------------
function init(self)
	msg.post(".", "acquire_input_focus")

        -- Allows access to the states and data directly for things such as condition checks.
	self.states = {
		idle = idleState,
		run = runState,
		air = airState,
		fall = fallState,
		jump = jumpState,
		land = landState
	}

	self.fsm = fsm.createMachine(self.states, playerState)
	self.fsm:changeState(self, "fall")  -- Player starts off falling down
end
```

# Super State

This is an optional state module that contains functions that can be accessed from within a sub state. IE:
```lua
local M = {}

M.gravity = -2200
M.jump_takeoff_speed = 1100
M.max_speed = 500
M.air_acceleration_factor = 0.8
M.ANGLE_THRESHOLD = 46
M.NORMAL_THRESHOLD = 0.7

---------------------------------
-- Common gravity for states
-- That support slopes
---------------------------------
function M.ApplyGravity(parent, pos, dt)

	parent.velocity.y = parent.velocity.y + (gravity * dt)
	if parent.velocity.y < -1250.0 then 
		parent.velocity.y = -1250.0
	end
	pos = (pos + parent.velocity * dt)

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

```

Once all the above is successful, `update()` and `input()` can be accessed within the FSM by using the below...

```lua
------------------------------------
-- Input
------------------------------------
function on_input(self, action_id, action)
	self.fsm:input(self, action_id, action)  -- Call to state machine
end


------------------------------------
-- Update
------------------------------------
function update(self, dt)  -- or fixed_update(self, dt)  
	self.fsm:fixed_update(self, dt)  -- Call to state machine
end
```

## Notes

### Access to States

In Defold, each script that utilizes the FSM should contain at minimum a `function init(self, parent)` function. 

In this implementation, manual positioning of any moving objects that are altered by a State, should be handled in that State's `update()` function.

Use of the update function requires having placed either a `update(self, parent, dt)` or a `fixed_update(self, parent, dt)` function, being physics dependent, within the module state code block as seen above.

Note: <a href="modules/fsm_engine.lu">`/modules/fsm_engine.lua`</a> has code included that enables access to the functions within the `PLAYERSTATE` module, which is optional.



### Is this production ready?

I use this implementation in my current game, and I haven't run into any issues as of yet. I believe it to be flexible, and if you know what you are doing, 
you can make it work to your liking. Feel free to use and/or modify it as you see fit. 

My current implementation is for my 2D Platformer, Shibori-Land.

