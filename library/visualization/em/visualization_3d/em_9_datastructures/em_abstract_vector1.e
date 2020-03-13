indexing
	description: " A simple 1D-Vector. "

	date: "$Date: 2006/09/04 08:35:53 $"
	revision: "$Revision: 1.9 $"

deferred class
	EM_ABSTRACT_VECTOR1[N -> NUMERIC]

inherit

	EM_ABSTRACT_VECTOR[N]
		undefine
			default_create
		end

	ANY
		undefine
			default_create,
			is_equal
		end

feature -- Access
	is_equal(other: like Current): BOOLEAN is
			-- are two vectors equal?
		do
			Result := x = other.x
		end

	x: N

	set_x ( value: like x ) is
			-- Specify x
		do
			x := value
		ensure
			x_set: x = value
		end

	dimension: INTEGER is 1
			-- Dimension

	zero: like Current is
			-- Zero vector
		deferred
		ensure then
			x_set: Result.x = 0
		end

	one: like Current is
			-- Vector containing a 1 in each dimension
		deferred
		ensure then
			x_set: Result.x = 1
		end

	element, item alias "[]", infix "@" (i: INTEGER): N assign set_element is
			-- Returns element number i of the vector
		do
			check i = 1 end
			Result := x
		end

feature -- Initialization
	make( a_x: like x ) is
			-- creates a vector from 2 components
		do
			x := a_x
		end


	make_from_tuple( t: TUPLE[N] ) is
			-- Create a vector from a tuple eg. [1]
		deferred
		end

	make_from_tuplei( t: TUPLE[INTEGER] ) is
			-- Create a vector from a tuple eg. [1]
		deferred
		end

	make_from_tuplef( t: TUPLE[REAL] ) is
			-- Create a vector from a tuple eg. [1]
		deferred
		end

	make_from_tupled( t: TUPLE[DOUBLE] ) is
			-- Create a vector from a tuple eg. [1]
		deferred
		end

	make_from_reference ( vec: like Current ) is
			-- create the vector from a ref
		deferred
		ensure then
			x_set: x = vec.x
		end

	fill, make_filled ( a_value: N ) is
			-- Fill vector with 'a_value'
		do
			x := a_value
		ensure then
			x_set: x = a_value
		end

	default_create is
			-- creates a vector set to 0
		deferred
		end

feature -- Commands
	set_element, put (a_value: N; i: INTEGER) is
			-- Sets the selected element to 'a_value'.
		do
			inspect i

			when 1 then
				x := a_value
			else
				check false end
			end
		end

	norm: N is
			-- returns the norm(length*length) of the vector
		do
			result := dot_product(Current)
		end

	length alias "||": N is
			-- returns the length of the vector
		deferred
		end

	scale ( factor: N ) is
			-- scale the vector
		do
			x := x * factor
		ensure then
			x_set: x = old x * factor
		end

	scaled alias "*" ( factor: N ) : like Current is
			-- returns the length of the vector
		deferred
		ensure then
			x_set: Result.x = factor * x
		end

	normalized: like Current is
			-- return a normalized vector
		do
			result := Current*(length.one/length)
		end

	ew_multiply ( a_factor: like Current) is
			-- Multiplies the operand 'a_factor' element wise on 'Current'
		do
			x := x * a_factor.x
		ensure then
			-- x = old x * a_factor.x
		end


	ew_multiplied ( a_factor: like Current) : like current is
			-- Returns a new vector constructed by element wise multiplication of the operands 'Current' and 'a_factor'
		deferred
		end

	ew_divide ( a_divisor: like Current) is
			-- Divides 'Current' through 'a_divisor'
		do
			x := x / a_divisor.x
		ensure then
			-- x = old x / a_factor.x
		end

	ew_divided ( a_divisor: like Current) : like current is
			-- Returns a new vector constructed by element wise division of the operands 'Current' and 'a_divisor'
		deferred
		end

	add, ew_add ( other: like Current) is
			-- Add the vector to Current.
		do
			x := x + other.x
		ensure then
			-- x_set: x = old x + other.x
		end

	sub, ew_subtract ( other: like Current) is
			-- Subtract the vector 'other' from Current.
		do
			x := x - other.x
		ensure then
			-- x_set: x = old x - other.x
		end

	infix "+", ew_added ( other: like Current ): like Current is
			-- adds two vectors
		deferred
		ensure then
			-- x_set: Result.x = x + other.x
		end

	infix "-", ew_subtracted ( other: like Current ): like Current is
			-- substracts two vectors
		deferred
		ensure then
			-- x_set: Result.x = x - other.x
		end


feature -- Conversion

	to_tuple: TUPLE[N] is
			-- convert to a tuple
		do
			result := [x]
		end

	to_c: ANY is
			-- Address of actual sequence of values,
			-- for passing to external (non-Eiffel) routines.
		do
			result := Current
		end

	to_reference: EM_ABSTRACT_VECTOR1[N] is
			-- Associated reference of Current
		deferred
		ensure
			to_reference_not_void: Result /= Void
			-- x_set: Result.x = x
		end

	to_pointer: POINTER is
			-- Convert to c-pointer
		do
			result := $Current
		end

end
