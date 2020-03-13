indexing
	description: " A simple 2D-Vector. "

	date: "$Date: 2006/08/28 16:50:04 $"
	revision: "$Revision: 1.9 $"

class
	EM_VECTOR2F_REF

inherit
	EM_ABSTRACT_VECTOR2[REAL]
	rename
		make_from_tuplef as make_from_tuple
	end

create
	make,
	default_create

feature -- Initialization

	make_from_tuplei( t: TUPLE[INTEGER, INTEGER] ) is
			-- Create a vector from a tuple eg. [1,2]
		do
			x := t.integer_item(1)
			y := t.integer_item(2)
		end

	make_from_tuple( t: TUPLE[REAL, REAL] ) is
			-- Create a vector from a tuple eg. [1,2]
		do
			x := t.real_item(1)
			y := t.real_item(2)
		end

	make_from_tupled( t: TUPLE[DOUBLE, DOUBLE] ) is
			-- Create a vector from a tuple eg. [1,2]
		do
			x := t.double_item(1)
			y := t.double_item(2)
		end

	make_from_reference ( vec: EM_VECTOR2F_REF ) is
			-- create the vector from a ref
		do
			make( vec.x, vec.y )
		end

	make_filled_d, fill_d (a_value: DOUBLE) is
			-- Fills the vector with 'a_value'
		do
			x := a_value
			y := a_value
		end

	default_create is
			-- creates a vector set to 0
		do
			x := 0
			y := 0
		ensure then
			x_set: x = 0
			y_set: y = 0
		end

feature -- Access
	zero: like Current is
		do
			create Result.make(0, 0)
		end

	one: like Current is
		do
			create Result.make(1, 1)
		end



feature -- Commands

	length alias "||": REAL is
			-- returns the length of the vector
		do
			Result := sqrt(norm)
		end

	scaled alias "*" ( factor: REAL ) : like Current is
			-- returns the length of the vector
		do
			create result.make( factor*x, factor*y )
		end

	scale_d ( factor: DOUBLE) is
			-- Scales the vector.
		do
			x := factor * x
			y := factor * y
		end

	scaled_d ( factor: DOUBLE) : like Current is
			-- Returns a new scaled vector
		do
			create Result.make((factor * x).rounded, (factor * y).rounded)
		end

	dot_product ( other: like Current ): REAL is
			-- not mutch to say here
		do
			result := x*other.x + y*other.y
		end

	ew_multiplied  ( other: like Current ): like Current is
			-- Multiplies two vectors element wise
		do
			create result.make( x*other.x, y*other.y )
		end

	ew_divided  ( other: like Current ): like Current is
			-- Divides two vectors element wise
		do
			create result.make( x/other.x, y/other.y )
		end

	infix "+", ew_added ( other: like Current ): like Current is
			-- Adds two vectors.
		do
			create result.make( x+other.x, y+other.y )
		end

	infix "-", ew_subtracted ( other: like Current ): like Current is
			-- Subtracts two vectors.
		do
			create result.make( x-other.x, y-other.y )
		end

	prefix "-" : like Current is
			-- Negates the vector
		do
			create result.make( -x, -y )
		end


feature -- Conversion
	to_vector1i: EM_VECTOR1I is
			-- convert to a 1d vector
		do
			Result.set(x.rounded)
		end

	to_vector2i: EM_VECTOR2I is
			-- convert to a 2d vector
		do
			Result.set(x.rounded, y.rounded)
		end

	to_vector3i: EM_VECTOR3I is
			-- convert to a 3d vector
		do
			result.set(x.rounded, y.rounded, 0)
		end

	to_vector4i: EM_VECTOR4I is
			-- convert to a 4d vector
		do
			result.set(x.rounded,y.rounded,0,0)
		end

	to_vector1d: EM_VECTOR1D is
			-- convert to a 1d vector
		do
			Result.set(x)
		end

	to_vector2d: EM_VECTOR2D is
			-- convert to a 2d vector
		do
			Result.set(x, y)
		end

	to_vector3d: EM_VECTOR3D is
			-- convert to a 3d vector
		do
			result.set(x,y,0)
		end

	to_vector4d: EM_VECTOR4D is
			-- convert to a 4d vector
		do
			result.set(x,y,0,0)
		end


	to_vector1f: EM_VECTOR1F is
			-- convert to a 1d vector
			-- There might be a data loss
		do
			result.set(x)
		end

	to_vector2f: EM_VECTOR2F is
			-- convert to a 2d vector
			-- There might be a data loss
		do
			result.set(x,y)
		end

	to_vector3f: EM_VECTOR3F is
			-- convert to a 3d vector
			-- There might be a data loss
		do
			result.set(x,y,0)
		end

	to_vector4f: EM_VECTOR4F is
			-- convert to a 4d vector
			-- There might be a data loss
		do
			result.set(x,y,0,0)
		end

	to_reference: EM_VECTOR2F_REF is
			-- Associated reference of Current
		do
			create Result.make(x,y)
		end

end
