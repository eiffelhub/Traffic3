indexing
	description: "Array for 3-dimensional vectors"
	author: ""
	date: "$Date: 2006/10/17 22:27:35 $"
	revision: "$Revision: 1.3 $"

deferred class
	EM_ABSTRACT_VECTOR3_ARRAY[N -> NUMERIC, V -> EM_ABSTRACT_VECTOR3[N]]

inherit
	EM_ABSTRACT_VECTOR_ARRAY[N, V]

convert
	to_c_pointer: {POINTER}

feature -- Element change

		put (v: V; i: INTEGER) is
				-- Replace `i'-th entry, if in index interval, by `v'.
			do
				area.put (v.x, dimension*i  )
				area.put (v.y, dimension*i + 1)
				area.put (v.z, dimension*i + 2)
			end

feature {NONE} -- Implementation
	dimension: INTEGER is 3

invariant
	invariant_clause: True -- Your invariant here

end
