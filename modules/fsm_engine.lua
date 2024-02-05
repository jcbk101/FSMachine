
-- Main State Machine GLOBAL variable
local M = {}


-------------------------------------------
--
-------------------------------------------
local function linkMetaTables( tbls, FSM )
	-- Loop through table and assign metatable to all nested tables
	for i, tbl in pairs(tbls) do
		if type(tbl) == "table" then
			setmetatable(tbl, FSM)
		end
	end
end

-------------------------------------------
--
-------------------------------------------
function M.createMachine( states )

	-- assert( states, "Error: Machines need to be pssed to this class." )
	-- assert( #states == 0, "Error: Machines need to be pssed to this class." )
	
	local FSM = { 
		is_paused = false, 
		states = states or {},
		currentState = nil,
		lastState = nil,
	}

	-- Link metatables
	FSM.__index = FSM
	linkMetaTables(FSM.states, FSM)

	FSM.currentState = nil
	FSM.lastState = nil


	-----------------------------------------------
	-- Transition to a new state: Setter :)
	-----------------------------------------------
	function FSM:changeState( parent, requestedState )
		-- State must exist!
		if FSM.states[ requestedState ] == nil then
			return nil
		end

		-- Exit code call for the last state
		if FSM.lastState then
			if FSM.currentState.exit then
				FSM.currentState:exit(parent)
			end 
		end

		-- Save ref to the state being changed to
		FSM.lastState = requestedState
		-- Get the state requested and run it
		FSM.currentState = FSM.states[ requestedState ]

		-- Run init code
		if FSM.currentState.init and FSM.currentState.init ~= FSM.init then
			FSM.currentState:init(parent)
		end 
	end

	-----------------------------------------------
	-- Handle state inputs
	-----------------------------------------------
	function FSM:input(parent, action_id, action)
		if FSM.currentState.input and FSM.currentState.input ~= FSM.input then
			FSM.currentState:input(parent, action_id, action)
		end
	end

	-----------------------------------------------
	-- Handle state fixed update
	-----------------------------------------------
	function FSM:fixed_update(parent, dt)
		if FSM.currentState.fixed_update and FSM.currentState.fixed_update ~= FSM.fixed_update then
			FSM.currentState:fixed_update(parent, dt)
		end
	end

	-----------------------------------------------
	-- Handle state update
	-----------------------------------------------
	function FSM:update(parent, dt)
		if FSM.currentState.update and FSM.currentState.update ~= FSM.update then
			FSM.currentState:update(parent, dt)
		end
	end

	-----------------------------------------------
	-- Getter 
	-----------------------------------------------
	function FSM.getState()
		return FSM.currentState
	end

	return FSM
end

return M