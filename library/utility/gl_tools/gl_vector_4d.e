note
	description: "[
		
		A 4-dimensional vector that can be used with OpenGL.
		Note: this is a simple implementation which doesn't allow any mathematics.

	]"
	date: "$Date: 2005/09/05 11:08:11 $"
	revision: "$Revision: 1.1 $"

class
	GL_VECTOR_4D [G]

inherit
	GL_VECTOR_3D [G]
		redefine
			out,
			debug_output
		 end

create
	make_xyzt

feature {NONE} -- Initialisation

	make_xyzt (a_x, a_y, a_z, a_t: G)
			-- Initialise `Current' with values `a_x' `a_y' `a_z' `a_t'.
		require
			a_x_not_void: a_x /= Void
			a_y_not_void: a_y /= Void
			a_z_not_void: a_z /= Void
			a_t_not_void: a_z /= Void
		do
			create array.make (0,3)
			set_xyzt (a_x, a_y, a_z, a_t)
		ensure
			x_set: x = a_x
			y_set: y = a_y
			z_set: z = a_z
			t_set: t = a_t
		end

feature -- Access

	t: G
			-- Fourth element
		do
			Result := array @ (3)
		ensure
			result_exists: Result /= Void
		end

feature -- Element change

	set_xyzt (a_x, a_y, a_z, a_t: G) 
			-- Set the values to `a_x' `a_y' `a_z' `a_t'.
		require
			a_x_not_void: a_x /= Void
			a_y_not_void: a_y /= Void
			a_z_not_void: a_z /= Void
			a_t_not_void: a_z /= Void
		do
			array.put (a_x, 0)
			array.put (a_y, 1)
			array.put (a_z, 2)
			array.put (a_t, 3)
		ensure
			x_set: x = a_x
			y_set: y = a_y
			z_set: z = a_z
			t_set: t = a_t
		end

feature -- Support

	out, debug_output: STRING
			-- Convert to string.
		do
			create Result.make_from_string (x.out+"/"+y.out+"/"+z.out)
		end

end
