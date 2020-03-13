indexing
	description: "A C-Array for 4D-Vectors"
	documentation: "Wraps  EM_VECTOR_3D to a c-array"
	date: "$Date: 2006/10/17 22:27:36 $"
	revision: "$Revision: 1.5 $"

class EM_VECTOR4F_ARRAY

inherit
	EM_ABSTRACT_VECTOR4_ARRAY[REAL, EM_VECTOR4F]

create
	make

convert
	to_c_pointer: {POINTER}

feature -- Access

	item alias "[]", infix "@" (i: INTEGER): EM_VECTOR4F assign put is
			-- Entry at index `i', if in index interval
		do
			Result := [ area.item (i* dimension + 0), area.item (i*dimension  + 1), area.item(i*dimension + 2), area.item(i*dimension + 3) ]
		end

end -- class EM_VECTOR_4F_ARRAY
