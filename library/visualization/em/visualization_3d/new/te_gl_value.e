indexing
	description: "[
		
		like GL_VECTOR_3D, this is a value that can be used with OpenGL.
		Note: this is a simple implementation which doesn't allow any mathematics.

	]"
	date: "$Date: 2005/09/05 11:08:11 $"
	revision: "$Revision: 1.1 $"

class
	TE_GL_VALUE [G]

inherit
	ANY
		redefine
			out
		end

	DEBUG_OUTPUT
		redefine
			out
		end

create
	make

feature {NONE} -- Initialisation

	make (a_value: G) is
			-- Initialise `Current' with value a_value
		require
			a_value_not_void: a_value /= Void
		do
			create array.make (0, 0)
			set_value (a_value)
		ensure
			value_set: value = a_value
		end

	make_from_other (other: like Current) is
			-- Initialise `Current' with values from `other'.
		require
			other_not_void: other /= Void
		do
			make (other.value)
		ensure
			value_set: value = other.value
		end

feature -- Access

	value: G is
			-- First element
		do
			Result := array @ (0)
		ensure
			result_exists: Result /= Void
		end

	pointer: POINTER is
			-- Pointer to `Current' which can be used in OpenGL
		local
			tmp: ANY
		do
			tmp := array.to_c
			Result := $tmp
		end

feature -- Element change

	set_value (a_value: G) is
			-- Set value to a_value.
		require
			a_value_void: a_value /= Void
		do
			array.put (a_value, 0)
		ensure
			value_set: value = a_value
		end

feature -- Support

	out, debug_output: STRING is
			-- Convert to string.
		do
			create Result.make_from_string (value.out)
		end

feature {NONE} -- Implementation

	array: ARRAY [G]
			-- The array to hold the elements

end
