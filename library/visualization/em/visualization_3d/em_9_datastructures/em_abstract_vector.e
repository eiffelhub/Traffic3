indexing
	description: "Abstract vector"
	author: ""
	date: "$Date: 2006/09/04 08:35:53 $"
	revision: "$Revision: 1.11 $"

deferred class
	EM_ABSTRACT_VECTOR[G -> NUMERIC]

inherit

	DOUBLE_MATH
		export
			{NONE} all
		undefine
			is_equal
		end

	ANY
	undefine
		is_equal
	end
feature -- Initialization

	make_filled, fill (a_value: G) is
			-- Fill the whole vector with 'a_value'.
		deferred
		end

	make_filled_d, fill_d (a_value: DOUBLE) is
			-- Fill the whole vector with 'a_value'.
		deferred
		end

feature -- Access

	dimension: INTEGER is
			-- Dimension of vector.
			-- Used inter alia in contracts
		deferred
		end

	one: like Current is
			-- All ones [1,1,... ,1]
		deferred
		end

	zero: like Current
			-- All zeros [0,0,...,0]
		deferred
		end

	element, item alias "[]", infix "@" (i: INTEGER): G assign set_element is
			-- Returns element number i of the vector
		Require
			i_in_range: i >= 1 and i <= dimension
		deferred
		end



feature -- Initialization
	make_from_reference ( vec: like Current ) is
			-- create the vector from a ref
		deferred
		end

feature -- Commands

	set_element, put (a_value: G; i: INTEGER) is
			-- Sets the selected element to 'a_value'.
		Require
			i_in_range: i >= 1 and i <= dimension
		deferred
		ensure
			a_value_set: element(i) = a_value
		end

	norm: G is
			-- returns the norm(length*length) of the vector
		deferred
		end

	length alias "||": G is
			-- returns the length of the vector
		deferred
		end

	normalized: like Current is
			-- return a normalized vector
		require
			length_bigger_zero: not Current.is_equal(zero)
		deferred
		end

	normalize is
			-- normalize the vector
		require
			length_bigger_zero: not Current.is_equal(zero)
		do
			scale(length.one / length)
		end

	scale ( factor: G) is
			-- Scales the vector.
		deferred
		end

	scaled alias "*" ( factor: G) : like Current is
			-- Returns a new scaled vector
		deferred
		end

	scale_d ( factor: DOUBLE) is
			-- Scales the vector.
		deferred
		end

	scaled_d ( factor: DOUBLE) : like Current is
			-- Returns a new scaled vector
		deferred
		end

	ew_multiply ( a_factor: like Current) is
			-- Multiplies the operand 'a_factor' element wise on 'Current'
		deferred
		end


	ew_multiplied ( a_factor: like Current) : like current is
			-- Returns a new vector constructed by element wise multiplication of the operands 'Current' and 'a_factor'
		deferred
		end

	ew_divide ( a_divisor: like Current)
			-- Divides 'Current' through 'a_divisor'
		deferred
		end

	ew_divided ( a_divisor: like Current) : like current is
			-- Returns a new vector constructed by element wise division of the operands 'Current' and 'a_divisor'
		deferred
		end

	dot_product ( other: like Current ): G is
			-- Ordinary well known dot product for vectors.
		require
			dimensions_match: Current.dimension = other.dimension
		deferred
		end

	add, ew_add ( other: like Current) is
			-- Add the vector to Current.
		require
			dimensions_match: Current.dimension = other.dimension
		deferred
		end

	sub, ew_subtract ( other: like Current) is
			-- Subract the 'other' vector by Current.
		require
			dimensions_match: Current.dimension = other.dimension
		deferred
		end

	infix "+", ew_added ( other: like current ): like current is
			-- Adds two vectors and returns a new instance
		require
			dimensions_match: Current.dimension = other.dimension
		deferred
		end

	infix "-", ew_subtracted ( other: like current ): like current is
			-- Subtracts two vectors and returns a new instance
		require
			dimensions_match: Current.dimension = other.dimension
		deferred
		end

	prefix "-" : like current is
			-- negates the vector
		deferred
		end

feature -- Conversion
	to_vector1i: EM_VECTOR1I is
			-- convert to a 1d vector
		deferred
		end


	to_vector2i: EM_VECTOR2I is
			-- convert to a 2d vector
		deferred
		end

	to_vector3i: EM_VECTOR3I is
			-- convert to a 3d vector
			-- There might be a data loss
		deferred
		end

	to_vector4i: EM_VECTOR4I is
			-- convert to a 4d vector
			-- There might be a data loss
		deferred
		end


	to_vector1f: EM_VECTOR1F is
			-- convert to a 1d vector
		deferred
		end


	to_vector2f: EM_VECTOR2F is
			-- convert to a 2d vector
		deferred
		end

	to_vector3f: EM_VECTOR3F is
			-- convert to a 3d vector
			-- There might be a data loss
		deferred
		end

	to_vector4f: EM_VECTOR4F is
			-- convert to a 4d vector
			-- There might be a data loss
		deferred
		end

	to_vector1d: EM_VECTOR1D is
			-- convert to a 1d vector
		deferred
		end

	to_vector2d: EM_VECTOR2D is
			-- convert to a 2d vector
		deferred
		end

	to_vector3d: EM_VECTOR3D is
			-- convert to a 3d vector
		deferred
		end

	to_vector4d: EM_VECTOR4D is
			-- convert to a 4d vector
		deferred
		end

feature {NONE} -- Implementation

invariant
	invariant_clause: True -- Your invariant here

end
