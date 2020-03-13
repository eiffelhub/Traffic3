indexing
	description: "A C-Array for 1D-Vectors"
	documentation: "Wraps  EM_VECTOR_3D to a c-array"
	date: "$Date: 2006/10/17 22:27:36 $"
	revision: "$Revision: 1.2 $"

class EM_VECTOR1D_ARRAY

inherit
	EM_ABSTRACT_VECTOR1_ARRAY[DOUBLE, EM_VECTOR1D]

create
	make

convert
	to_c_pointer: {POINTER}

feature -- Access

	item alias "[]", infix "@" (i: INTEGER): EM_VECTOR1D assign put is
			-- Entry at index `i', if in index interval
		do
			Result := [ area.item (i* dimension + 0) ]
		end

end -- class EM_VECTOR_1D_ARRAY
