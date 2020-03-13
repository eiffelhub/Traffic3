indexing
	description: "A C-Array for Vectors"
	documentation: "Wraps  EM_VECTOR_3D to a c-array"
	date: "$Date: 2006/10/17 22:27:36 $"
	revision: "$Revision: 1.3 $"

deferred class EM_ABSTRACT_VECTOR_ARRAY[N -> NUMERIC, V -> EM_ABSTRACT_VECTOR[N]]

inherit
	TO_SPECIAL[N]
	rename
		put as put_double,
		valid_index as valid_index_double,
		item as item_double,
		infix "@" as infix "@@"
	export
		{NONE} put_double,valid_index_double, item_double, infix "@@"
	end

convert
	to_c_pointer: {POINTER}

feature {NONE} -- Initialization
	make( n: INTEGER ) is
			-- make a new vector array, numbered from 0!
		do
			make_area( n*dimension )
			capacity := n
			count := n
		end

feature -- Access

	item alias "[]", infix "@" (i: INTEGER): V assign put is
			-- Entry at index `i', if in index interval
		require
			valid_index: valid_index (i)
		deferred
			-- Implementation should look like this (depending on the dimension):
			-- Result := [ area.item (i* dimension + 0), ..., area.item (i*dimension  + n)]
		end

feature -- Status report
	valid_index (i: INTEGER): BOOLEAN is
			-- Is `i' within the bounds of Current?
		do
			Result := (lower <= i) and then (i <= upper)
		end

feature -- Element change

		put (v: V; i: INTEGER) is
				-- Replace `i'-th entry, if in index interval, by `v'.
			require
				valid_index: valid_index (i)
			deferred
			ensure
				inserted: item (i) = v
			end
		force( v: V; i: INTEGER) is
				-- Replace `i'-th entry, if in index interval, by `v'.
				-- Resize if i is not a valid_index
			require
				i_is_positive: i>=0
			do
				if i >= count then
					resize( i+1 )
				end
				put( v, i )
			end

feature {ANY} -- Access
	count: INTEGER
	lower: INTEGER is 0
	upper: INTEGER is
			-- Upper element bound
		do
			result := count-1
		end

	resize( a_new_size: INTEGER ) is
			-- resize the array
		require
			a_new_size_greater_than_count: a_new_size > count
		do
			if capacity < a_new_size then
				-- Its much faster than just always adding a certain amount!
				if capacity = 0 then
					capacity := 1
				end
				from until capacity >= a_new_size loop
					capacity := capacity*2
				end
				area := area.aliased_resized_area( capacity*dimension )
			end
			count := a_new_size
		end

	to_c: ANY is
			-- Convert to C
		do
			result :=  area
		end

	to_c_pointer: POINTER is
			-- Convert to c pointer
		do
			result := $area
		end

feature {NONE} -- Implementation
	capacity: INTEGER

	dimension: INTEGER is
			-- the dimension of the Vector
		deferred
		end

end -- class EM_ABSTRACT_VECTOR_ARRAY
