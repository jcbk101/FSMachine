# Defold 2D Platform Finite State Machine

In this project you will find an example of a simple Finite State Machine implementation for the <a href="www.defold.com">Defold game engine</a>, using Lua, without any plugins.

You will find FSM Controller under `/modules/fsm_engine.lua`. Example code is in `/main/main.script`.

A video showing this example can be found at: https://www.youtube.com/watch?v=42PGvmFFeWI


## What can the State Machine do?

### Example: Script file
`./main/main.script`
####
In the main script file, all states are created as local tables. IE: 

```lua
------------------------------------
--
------------------------------------
local idleState = {
	init = function(self, parent)
		self.is_exiting = false
		--
		if go.get("#sprite", "animation") ~= hash("idle") then
			sprite.play_flipbook("#sprite", "idle")
		end
		parent.velocity.x = 0
	end,

	exit = function(self, parent)
		self.is_exiting = true
	end,

	input = function(self, parent, action_id, action)
		if not self.is_exiting then
			if (action_id == hash("left") or action_id == hash("right")) and (action.value and action.value > 0) then
				self:changeState(parent, "run")

			elseif action_id == hash("jump") and parent.states.jump:CanJump() then
				self:changeState(parent, "jump")
			end
		end		
	end,

	-- Local variables
	is_exiting = false
}
```


## Notes

### Access to States

In Defold, each script that utilizes the FSM should contain at minimum a `function init(self)` function. 

In this implementation, manual positioning of any moving objects that are altered by a State, should be handled in that State's `update()` function.

Use of the update function requires having placed either a `update(self, parent, dt)` or a `fixed_update(self, parent, dt)` function, being physics dependent.

Note: I am attempting to figure a way to utilize multiple scripts attached to a single GO. This will allow for much cleaner code and state structure.


### Is this production ready?

I use this implementation in my current game, and I haven't run into any issues as of yet. I believe it to be flexible, and if you know what you are doing, 
you can make it work to your liking. Feel free to use and/or modify it as you see fit. 

My current implementation is for my 2D Platformer, Shibori-Land.

