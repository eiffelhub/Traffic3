indexing
	description: "Array for 2-dimensional vectors"
	author: ""
	date: "$Date: 2006/10/17 22:27:36 $"
	revision: "$Revision: 1.2 $"

deferred class
	EM_ABSTRACT_VECTOR2_ARRAY[N -> NUMERIC, V -> EM_ABSTRACT_VECTOR2[N]]

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
			end

feature {NONE} -- Implementation
	dimension: INTEGER is 2

invariant
	invariant_clause: True -- Your invariant here

end
