indexing
	description: "Array for 1-dimensional vectors"
	author: ""
	date: "$Date: 2006/08/21 15:39:17 $"
	revision: "$Revision: 1.2 $"

deferred class
	EM_ABSTRACT_VECTOR1_ARRAY[N -> NUMERIC, V -> EM_ABSTRACT_VECTOR1[N]]

inherit
	EM_ABSTRACT_VECTOR_ARRAY[N, V]

feature -- Element change

		put (v: V; i: INTEGER) is
				-- Replace `i'-th entry, if in index interval, by `v'.
			do
				area.put (v.x, dimension*i)
			end

feature {NONE} -- Implementation
	dimension: INTEGER is 1

invariant
	invariant_clause: True -- Your invariant here

end
