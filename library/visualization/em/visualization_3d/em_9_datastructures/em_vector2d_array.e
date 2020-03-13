indexing
	description: "A C-Array for 2D-Vectors"
	documentation: "Wraps  EM_VECTOR_3D to a c-array"
	date: "$Date: 2006/10/17 22:27:36 $"
	revision: "$Revision: 1.4 $"

class EM_VECTOR2D_ARRAY

inherit
	EM_ABSTRACT_VECTOR2_ARRAY[DOUBLE, EM_VECTOR2D]

create
	make

convert
	to_c_pointer: {POINTER}

feature -- Access

	item alias "[]", infix "@" (i: INTEGER): EM_VECTOR2D assign put is
			-- Entry at index `i', if in index interval
		do
			Result := [ area.item (i* dimension + 0), area.item (i*dimension  + 1) ]
		end

end -- class EM_VECTOR_2D_ARRAY
