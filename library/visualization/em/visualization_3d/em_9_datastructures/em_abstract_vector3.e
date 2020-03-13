indexing
	description: "Generic parent class for 3D-Vector."

	date: "$Date: 2006/09/04 08:35:53 $"
	revision: "$Revision: 1.11 $"

deferred class
	EM_ABSTRACT_VECTOR3[N -> NUMERIC]

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
	x: N
	y: N
	z: N

	is_equal(other: like Current): BOOLEAN is
			-- are two vectors equal?
		do
			Result := x = other.x and y = other.y and z = other.z
		end


	set_x ( value: like x ) is
			-- Specify x
		do
			x := value
		ensure
			x_set: x = value
		end

	set_y ( value: like y ) is
			-- Specify y
		do
			y := value
		ensure
			y_set: y = value
		end


	set_z ( value: like z ) is
			-- Specify z
		do
			z := value
		ensure
			z_set: z = value
		end

	element, item alias "[]", infix "@" (i: INTEGER): N assign set_element is
			-- Returns element number i of the vector
		do
			inspect i

			when 1 then
				Result := x
			when 2 then
				Result := y
			when 3  then
				Result := z
			else
				check false end
			end
		end

	dimension: INTEGER is 3
			-- Dimension

	zero: like Current is
			-- Zero vector
		deferred
		ensure then
			x_set: Result.x = 0
			y_set: Result.y = 0
			z_set: Result.z = 0
		end

	one: like Current is
			-- Vector containing a 1 in each dimension
		deferred
		ensure then
			x_set: Result.x = 1
			y_set: Result.y = 1
			z_set: Result.z = 1
		end

feature -- Initialization

	make( a_x: like x; a_y: like y; a_z: like z ) is
			-- creates a vector from 2 components
		do
			x := a_x
			y := a_y
			z := a_z
		end

	make_from_tuple( t: TUPLE[N, N, N] ) is
			-- Create a vector from a tuple eg. [1,2]
		deferred
		end


	make_from_tuplei( t: TUPLE[INTEGER, INTEGER, INTEGER] ) is
			-- Create a vector from a tuple eg. [1,2]
		deferred
		end

	make_from_tuplef( t: TUPLE[REAL, REAL, REAL] ) is
			-- Create a vector from a tuple eg. [1,2]
		deferred
		end

	make_from_tupled( t: TUPLE[DOUBLE, DOUBLE, DOUBLE] ) is
			-- Create a vector from a tuple eg. [1,2]
		deferred
		end

	make_from_reference ( vec: like Current ) is
			-- create the vector from a ref
		deferred
		ensure then
			x_set: x = vec.x
			y_set: y = vec.y
			z_set: z = vec.z
		end

	fill, make_filled ( a_value: N ) is
			-- Fill vector with 'a_value'
		do
			x := a_value
			y := a_value
			z := a_value
		ensure then
			x_set: x = a_value
			y_set: y = a_value
			z_set: z = a_value
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
			when 2 then
				y := a_value
			when 3  then
				z := a_value
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
			y := y * factor
			z := z * factor
		ensure then
			-- x_set: x = old x * factor
			-- y_set: y = old y * factor
			-- z_set: z = old z * factor
		end

	scaled alias "*" ( factor: N ) : like Current is
			-- returns the length of the vector
		deferred
		ensure then
			-- x_set: Result.x = factor * x
			-- y_set: Result.y = factor * y
			-- z_set: Result.z = factor * z
		end

	normalized: like Current is
			-- return a normalized vector
		do
			result := Current*(length.one/length)
		end

	dot_product ( other: like Current ): N is
			-- not much to say here
		do
			result := x*other.x + y*other.y + z*other.z
		end

	cross_product ( other: like Current ): like Current is
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
		do
			x := x * a_factor.x
			y := z * a_factor.y
			z := z * a_factor.z
		ensure then
			-- x = old x * a_factor.x
			-- y = old z * a_factor.y
			-- z = old z * a_factor.z
		end


	ew_multiplied ( a_factor: like Current) : like current is
			-- Returns a new vector constructed by element wise multiplication of the operands 'Current' and 'a_factor'
		deferred
		end

	ew_divide ( a_divisor: like Current) is
			-- Divides 'Current' through 'a_divisor'
		do
			x := x / a_divisor.x
			y := z / a_divisor.y
			z := z / a_divisor.z
		ensure then
			-- x = old x / a_factor.x
			-- y = old z / a_factor.y
			-- z = old z / a_factor.z
		end

	ew_divided ( a_divisor: like Current) : like current is
			-- Returns a new vector constructed by element wise division of the operands 'Current' and 'a_divisor'
		deferred
		end

	add, ew_add ( other: like Current) is
			-- Add the vector to Current.
		do
			x := x + other.x
			y := y + other.y
			z := z + other.z
		ensure then
			-- x_set: x = old x + other.x
			-- y_set: y = old y + other.y
			-- z_set: z = old z + other.z
		end

	sub, ew_subtract ( other: like Current) is
			-- Subtract the vector 'other' from Current.
		do
			x := x - other.x
			y := y - other.y
			z := z - other.z
		ensure then
			-- x_set: x = old x - other.x
			-- y_set: y = old y - other.y
			-- z_set: z = old z - other.z
		end

	infix "+", ew_added ( other: like Current ): like Current is
			-- adds two vectors
		deferred
		ensure then
			-- x_set: Result.x = x + other.x
			-- y_set: Result.y = y + other.y
			-- z_set: Result.z = z + other.z
		end

	infix "-", ew_subtracted ( other: like Current ): like Current is
			-- substracts two vectors
		deferred
		ensure then
			-- x_set: Result.x = x - other.x
			-- y_set: Result.y = y - other.y
			-- z_set: Result.z = z - other.z
		end

	prefix "-" : like Current is
			-- negates the vector
		deferred
		ensure then
			-- x_set: Result.x = -x
			-- y_set: Result.y = -y
			-- z_set: Result.z = -z
		end

feature -- Conversion

	to_tuple: TUPLE[N, N, N] is
			-- convert to a tuple
		do
			result := [x,y,z]
		end

	to_c: ANY is
			-- Address of actual sequence of values,
			-- for passing to external (non-Eiffel) routines.
		do
			result := Current
		end

	to_reference: EM_ABSTRACT_VECTOR3[N] is
			-- Associated reference of Current
		deferred
		ensure
			to_reference_not_void: Result /= Void
			x_set: Result.x = x
			y_set: Result.y = y
			z_set: Result.z = z
		end

	to_pointer: POINTER is
			-- Convert to c-pointer
		do
			result := $Current
		end

end
