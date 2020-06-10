note
	description: "[
		
		A 3-dimensional vector that can be used with OpenGL.
		Note: this is a simple implementation which doesn't allow any mathematics.

	]"
	date: "$Date: 2005/09/05 11:08:11 $"
	revision: "$Revision: 1.1 $"

class
	GL_VECTOR_3D [G]

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
	make_xyz

feature {NONE} -- Initialisation

	make_xyz (a_x, a_y, a_z: G)
			-- Initialise `Current' with values `a_x' `a_y' `a_z'.
		require
			a_x_not_void: a_x /= Void
			a_y_not_void: a_y /= Void
			a_z_not_void: a_z /= Void
		do
			create array.make (0, 2)
			set_xyz (a_x, a_y, a_z)
		ensure
			x_set: x = a_x
			y_set: y = a_y
			z_set: z = a_z
		end

	make_from_other (other: like Current)
			-- Initialise `Current' with values from `other'.
		require
			other_not_void: other /= Void
		do
			make_xyz (other.x, other.y, other.z)
		ensure
			x_set: x = other.x
			y_set: y = other.x
			z_set: z = other.z
		end

feature -- Access

	x: G
			-- First element
		do
			Result := array @ (0)
		ensure
			result_exists: Result /= Void
		end

	y: G
			-- Second element
		do
			Result := array @ (1)
		ensure
			result_exists: Result /= Void
		end

	z: G
			-- Third element
		do
			Result := array @ (2)
		ensure
			result_exists: Result /= Void
		end

	pointer: POINTER
			-- Pointer to `Current' which can be used in OpenGL
		local
			tmp: ANY
		do
			tmp := array.to_c
			Result := $tmp
		end

feature -- Element change

	set_xyz (a, b, c: G) 
			-- Set values to `a' `b' `c'.
		require
			a_not_void: a /= Void
			b_not_void: b /= Void
			c_not_void: c /= Void
		do
			array.put (a, 0)
			array.put (b, 1)
			array.put (c, 2)
		ensure
			x_set: x = a
			y_set: y = b
			z_set: z = c
		end

feature -- Support

	out, debug_output: STRING
			-- Convert to string.
		do
			create Result.make_from_string (x.out+"/"+y.out+"/"+z.out)
		end

feature {NONE} -- Implementation

	array: ARRAY [G]
			-- The array to hold the elements

end
