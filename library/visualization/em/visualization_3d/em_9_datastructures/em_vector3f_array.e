indexing
	description: "A C-Array for 3D-Vectors"
	documentation: "Wraps  EM_VECTOR_3D to a c-array"
	date: "$Date: 2006/10/17 22:27:36 $"
	revision: "$Revision: 1.5 $"

class EM_VECTOR3F_ARRAY

inherit
	EM_ABSTRACT_VECTOR3_ARRAY[REAL, EM_VECTOR3F]

create
	make

convert
	to_c_pointer: {POINTER}

feature -- Access

	item alias "[]", infix "@" (i: INTEGER): EM_VECTOR3F assign put is
			-- Entry at index `i', if in index interval
		do
			Result := [ area.item (i* dimension + 0), area.item (i*dimension  + 1), area.item(i*dimension + 2) ]
		end

end -- class EM_VECTOR_3D_ARRAY
