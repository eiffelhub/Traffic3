note
	description: "State of line segment."
	date: "$Date: 2009-08-21 13:35:22 +0200 (Пт, 21 авг 2009) $"
	revision: "$Revision: 1098 $"

class
	TRAFFIC_SEGMENT_STATE

inherit

	ANY
		redefine
			out
		end

create
	make

feature {NONE} -- Inititalization

	make
			-- Set state to normal.
		do
			value := State_normal
		ensure
			value_valid: is_valid_state_value (value)
		end

feature -- Access

	value: INTEGER
			-- Current state.

feature -- Element change

	set_state (a_value: INTEGER)
			-- Set `value' to `a_value'.
		require
			is_valid_state_value (a_value)
		do
			value := a_value
		ensure
			value_set: value = a_value
		end

feature -- Constants

	State_normal, State_collision: INTEGER = unique
			-- State constants

feature -- Status report

	is_valid_state_value (a_state_value: INTEGER): BOOLEAN
			-- Is `a_state_value' a state constants?
		do
			Result := False

			inspect
				a_state_value
			when State_normal then
				Result := True
			when State_collision then
				Result := True
			end
		end

feature -- Basic operation

	to_string (a_state_value: INTEGER): STRING
			-- String representation of state `a_state_value'
		require
			a_state_value_valid: is_valid_state_value (a_state_value)
		do
			inspect
				a_state_value
			when State_normal then
				Result := "normal"
			when State_collision then
				Result := "collision"
			else
				Result := "not defined"
			end
		end

feature -- Basic operation

	out: STRING
			-- Textual representation
		do
			Result := "state: " + to_string (value)
		end

invariant
	value_valid: is_valid_state_value (value) -- Valid state value.

end
