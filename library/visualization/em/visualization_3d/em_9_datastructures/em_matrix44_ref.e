indexing
	description: " A 4x4 Matrix with basic operations"
	date: "$Date: 2006/11/06 15:29:09 $"
	revision: "$Revision: 1.5 $"

class
	EM_MATRIX44_REF

inherit
	DOUBLE_MATH
		export
			{NONE} all
		redefine
			out,
			default_create
		end
	ANY
		redefine
			out,
			default_create
		end

create
	default_create,
	make_empty,
	make_unit,
	make_from_tuple,
	make,
	make_from_quaternion,
	make_from_scalar,
	make_from_translation,
	make_from_rotation,
	make_from_reference

feature -- Access
	set_element( value: like element ; x: INTEGER; y: INTEGER) is
			-- Sets the element in the x'th column and the y'th row
		require
			1<=x and x<=4
			1<=y and x<=4
		do
			area.put( value, (x-1)*4 + (y-1) )
		end

	set_diagonal (v: EM_VECTOR4D) is
			-- Set diagonal to `v'
		do
			set_element (v.x, 1, 1)
			set_element (v.y, 2, 2)
			set_element (v.z, 3, 3)
			set_element (v.w, 4, 4)
		ensure
			set: diagonal = v
		end


	set_row (v: EM_VECTOR4D; i: INTEGER) is
			-- Set `i'th row to `v'
		require
			valid_index: 1 <= i and i <= 4
		do
			set_element (v.x, 1, i)
			set_element (v.y, 2, i)
			set_element (v.z, 3, i)
			set_element (v.w, 4, i)
		ensure
			set: row (i) = v
		end

	set_column (v: EM_VECTOR4D; i: INTEGER) is
			-- Set `i'th column to `v'
		require
			valid_index: 1 <= i and i <= 4
		do
			set_element (v.x, i, 1)
			set_element (v.y, i, 2)
			set_element (v.z, i, 3)
			set_element (v.w, i, 4)
		ensure
			set: column (i) = v
		end

	element alias "[]" ( x: INTEGER; y: INTEGER): DOUBLE assign set_element is
			-- returns the element in the x'th column and the y'th row
		require
			1<=x and x<=4
			1<=y and x<=4
		do
			result := area.item( (x-1)*4 + (y-1) )
		end

	diagonal: EM_VECTOR4D is
			-- Diagonal of current matrix as vector
		do
			Result.set (
				element (1, 1),
				element (2, 2),
				element (3, 3),
				element (4, 4)
			)
		end


	row (i: INTEGER): EM_VECTOR4D is
			-- `i'th row of current matrix as vector
		require
			valid_index: 1 <= i and i <= 4
		do
			Result.set (
				element (1, i),
				element (2, i),
				element (3, i),
				element (4, i)
			)
		end

	column (i: INTEGER): EM_VECTOR4D is
			-- `i'th column of current matrix as vector
		require
			valid_index: 1 <= i and i <= 4
		do
			Result.set (
				element (i, 1),
				element (i, 2),
				element (i, 3),
				element (i, 4)
			)
		end


feature {EM_MATRIX44_REF} -- Access
	area: SPECIAL[DOUBLE]
feature {NONE} -- Initialization
	make_from_reference (v: EM_MATRIX44_REF ) is
			-- Initialize `Current' with `v.area'.
		require
			v_not_void: v /= Void
		do
			area.copy_data( v.area, 0, 0, 16 )
		ensure
			item_set: area.is_equal ( v.area )
		end

feature -- Conversion

	to_reference: EM_MATRIX44_REF is
			-- Associated reference of Current
		do
			create Result
			Result.area.copy_data ( area, 0, 0, 16 )
		ensure
			to_reference_not_void: Result /= Void
		end


feature -- Initialize
	default_create is
			-- Make an ampty Matrix
		do
			make_empty
		end

	make_empty is
			-- Makes an empty Matrix
		do
			create area.make(16)
		ensure
			area.count = 16
		end

	make_from_vector_tuple( a: TUPLE[EM_VECTOR4D, EM_VECTOR4D, EM_VECTOR4D, EM_VECTOR4D] ) is
			-- Creates the matrix from an array (4x4 would be optimal)
		local
			vector_ref: EM_VECTOR4D_REF
		do
			make_empty
			vector_ref ?= a.reference_item (1)
			check
				vector_ref/=void
			end

			area.put( vector_ref.x, 0)
			area.put( vector_ref.y, 1)
			area.put( vector_ref.z, 2)
			area.put( vector_ref.w, 3)

			vector_ref ?= a.reference_item (2)
			check
				vector_ref/=void
			end

			area.put( vector_ref.x, 4)
			area.put( vector_ref.y, 5)
			area.put( vector_ref.z, 6)
			area.put( vector_ref.w, 7)

			vector_ref ?= a.reference_item (3)
			check
				vector_ref/=void
			end

			area.put( vector_ref.x, 8)
			area.put( vector_ref.y, 9)
			area.put( vector_ref.z, 10)
			area.put( vector_ref.w, 11)

			vector_ref ?= a.reference_item (4)
			check
				vector_ref/=void
			end

			area.put( vector_ref.x, 12)
			area.put( vector_ref.y, 13)
			area.put( vector_ref.z, 14)
			area.put( vector_ref.w, 15)
		end

		make_from_tuple( a: TUPLE[DOUBLE, DOUBLE, DOUBLE, DOUBLE,
								  DOUBLE, DOUBLE, DOUBLE, DOUBLE,
								  DOUBLE, DOUBLE, DOUBLE, DOUBLE,
								  DOUBLE, DOUBLE, DOUBLE, DOUBLE] ) is
			-- Creates the matrix from an array (4x4 would be optimal)
		local
			i: INTEGER
		do
			make_empty
			from
				i := a.lower
			until
				i > a.upper or i > a.lower+15
			loop
				area.put( a.double_item(i), i)
				i := i + 1
			end
		end


	make( a_11: DOUBLE; a_12: DOUBLE; a_13: DOUBLE; a_14: DOUBLE;
	      a_21: DOUBLE; a_22: DOUBLE; a_23: DOUBLE; a_24: DOUBLE;
	      a_31: DOUBLE; a_32: DOUBLE; a_33: DOUBLE; a_34: DOUBLE;
	      a_41: DOUBLE; a_42: DOUBLE; a_43: DOUBLE; a_44: DOUBLE ) is
			-- Creates a Matrix from the given elements
		do
			make_empty
			area.put( a_11, 0)
			area.put( a_21, 1)
			area.put( a_31, 2)
			area.put( a_41, 3)
			area.put( a_12, 4)
			area.put( a_22, 5)
			area.put( a_32, 6)
			area.put( a_42, 7)
			area.put( a_13, 8)
			area.put( a_23, 9)
			area.put( a_33, 10)
			area.put( a_43, 11)
			area.put( a_14, 12)
			area.put( a_24, 13)
			area.put( a_34, 14)
			area.put( a_44, 15)
		end

	make_unit is
			-- Make a unit matrix
		do
			make_empty
			area.put( 1, 0)
			area.put( 1, 5)
			area.put( 1, 10)
			area.put( 1, 15)
		end

	make_from_quaternion( q: EM_QUATERNION ) is
			-- Make a matrix from a Quaternion
		local
			x: DOUBLE
			y: DOUBLE
			z: DOUBLE
			w: DOUBLE
		do
			q.normalize
			x := q.v.x
			y := q.v.y
			z := q.v.z
			w := q.w

			make_empty

			area.put( 1 - 2 * (y*y + z*z), 0)
			area.put( 2 * (x*y + w*z), 1)
			area.put( 2 * (x*z - w*y), 2)
			area.put( 0, 3)

			area.put( 2 * (x*y - w*z), 4)
			area.put( 1 - 2 * (x*x + z*z), 5)
			area.put( 2 * (y*z + w*x), 6)
			area.put( 0, 7)

			area.put( 2 * (y*w + x*z), 8)
			area.put( 2 * (y*z - w*x), 9)
			area.put( 1 - 2 * (x*x + y*y), 10)
			area.put( 0, 11)

			area.put( 0, 12)
			area.put( 0, 13)
			area.put( 0, 14)
			area.put( 1, 15)
		end

	make_from_scalar( s: DOUBLE ) is
			-- Make a scalar matrix
		do
			make_empty
			area.put( s, 0)
			area.put( s, 5)
			area.put( s, 10)
			area.put( s, 15)
		end

	make_from_translation( v: EM_VECTOR3D ) is
			-- Make a scalar matrix
		do
			make_unit
			area.put( v.x, 12)
			area.put( v.y, 13)
			area.put( v.z, 14)
			area.put( 1, 15)
		end

	make_from_rotation( v: EM_VECTOR3D; angle: DOUBLE ) is
			-- Make a scalar matrix with angle in radian
		local
			s: DOUBLE
			c: DOUBLE
			vv: EM_VECTOR3D
			x: DOUBLE
			y: DOUBLE
			z: DOUBLE
		do
			s := sine ( angle )
			c := cosine ( angle )
			vv := v.normalized
			x := vv.x
			y := vv.y
			z := vv.z

			make_empty

			area.put( (x*x*(1-c)) + c, 0)
			area.put( (y*x*(1-c)) + z*s, 1)
			area.put( (z*x*(1-c)) - y*s, 2)
			area.put( 0, 3)

			area.put( (x*y*(1-c)) - z*s, 4)
			area.put( (y*y*(1-c)) + c, 5)
			area.put( (z*y*(1-c)) + x*s, 6)
			area.put( 0, 7)

			area.put( (x*z*(1-c)) + y*s, 8)
			area.put( (y*z*(1-c)) - x*s, 9)
			area.put( (z*z*(1-c)) + c, 10)
			area.put( 0, 11)

			area.put( 0, 12)
			area.put( 0, 13)
			area.put( 0, 14)
			area.put( 1, 15)
		end

feature -- Conversion
	to_c: ANY is
			-- Address of actual sequence of values,
			-- for passing to external (non-Eiffel) routines.
		do
			result := area
		end

	to_pointer: POINTER is
			-- Address of actual sequence of values,
			-- for passing to external (non-Eiffel) routines.
		do
			result := $area
		end

	to_c_real: ANY is
			-- Address of actual sequence of values,
			-- for passing to external (non-Eiffel) routines.
		obsolete
			"Do not use this function its dangerous, use a real matrix instead"
		local
			tmp: ARRAY[ REAL ]
			i: INTEGER
		do
			create tmp.make( 0, 15 )
			from i:=0 until i>15 loop
				tmp[i] := area[i]
			end
			result := tmp.to_c
		end



feature -- Commands
	multiply (other: like current) is
			-- Multiply two matrices
		local
			i: INTEGER
			j: INTEGER
			k: INTEGER
			t: DOUBLE
		do
			from i := 1 until i > 4 loop -- i'th collumn
				from j := 1 until j > 4 loop -- j'th row
					t := 0
					from k := 1 until k > 4 loop
						t := t + element(k, j)*other[i, k]
						k := k + 1
					end
					set_element( t, i, j )
					j := j + 1
				end
				i := i + 1
			end
		end

	infix "*" (other: like current): like Current is
			-- Multiply two matrices
		local
			i: INTEGER
			j: INTEGER
			k: INTEGER
			t: DOUBLE
		do
			create result
			from i := 1 until i > 4 loop -- i'th collumn
				from j := 1 until j > 4 loop -- j'th row
					t := 0
					from k := 1 until k > 4 loop
						t := t + element(k, j)*other[i, k]
						k := k + 1
					end
					result[i,j] := t
					j := j + 1
				end
				i := i + 1
			end
		end

	mult (other: EM_VECTOR4D): EM_VECTOR4D is
			-- Multiply a matrix and a vector
		do
			result.set( element(1,1)*other.x + element(2,1)*other.y + element(3,1)*other.z + element(4,1)*other.w,
						element(1,2)*other.x + element(2,2)*other.y + element(3,2)*other.z + element(4,2)*other.w,
						element(1,3)*other.x + element(2,3)*other.y + element(3,3)*other.z + element(4,3)*other.w,
						element(1,4)*other.x + element(2,4)*other.y + element(3,4)*other.z + element(4,4)*other.w)
		end

	scale (factor: DOUBLE) is
			-- Scales the 'Current' matrix by a 'factor'.
		local
			i: INTEGER
		do
			from i := area.lower until i > area.upper loop -- i'th element
				area[i] := area[i] * factor
				i := i + 1
			end
		end


	scaled (factor: DOUBLE): like Current is
			-- returns a the a scaled copy of the current matrix
		do
			create result
			result.scale( factor )
		end


	swap_rows( a, b: INTEGER) is
			-- Swap two rows
		local
			tmp: DOUBLE
		do
			tmp := element(1,a); set_element( element(1,b), 1,a); set_element( tmp, 1,a)
			tmp := element(2,a); set_element( element(2,b), 2,a); set_element( tmp, 2,a)
			tmp := element(3,a); set_element( element(3,b), 3,a); set_element( tmp, 3,a)
			tmp := element(4,a); set_element( element(4,b), 4,a); set_element( tmp, 4,a)
		end

	inverse is
			-- return the inverse, using gauss
			-- needs det!=0
		require
			det.abs > 0.00000001 -- tolerance
		local
			tmp: DOUBLE
			a,b: EM_MATRIX44
			i,j,jj: INTEGER
			jmax: INTEGER
		do
			a := twin
			b.set_unit
			from i:=1 until i>4 loop
				jmax := i
				from j := i+1 until j>4 loop
					if (a[i,jmax]).abs<(a[i,j]).abs then
						jmax := j -- CHANGED from i to j
					end
					j := j + 1
				end
				check
					(a[i,jmax]).abs>0.00000001
				end
				-- swap the rows
				a.swap_rows(i, jmax)
				b.swap_rows(i, jmax)

				tmp := 1/a[i,i]
				a[1,i] := a[1,i]*tmp
				a[2,i] := a[2,i]*tmp
				a[3,i] := a[3,i]*tmp
				a[4,i] := a[4,i]*tmp

				b[1,i] := b[1,i]*tmp
				b[2,i] := b[2,i]*tmp
				b[3,i] := b[3,i]*tmp
				b[4,i] := b[4,i]*tmp

				from j:=1 until j>4 loop
					if j/=i then
						tmp := a[i,j]
						from jj:=1 until jj>4 loop
							a[jj,j] := a[jj,j] - a[jj,i]*tmp
							b[jj,j] := b[jj,j] - b[jj,i]*tmp
							jj := jj + 1
						end
					end
					j := j + 1
				end

				i:=i+1
			end

			area := b.area
		end

	inversed: like current is
			-- return the inverse
			-- needs det!=0
		require
			det.abs > 0.0000000001 -- tolerance
		do
			result := twin
			result.inverse
		end

	srt_inversed: like current is
			-- assuming this is a homogenous SRT transformation matrix, it returns the inversed transformation matrix
		do
			result := twin
			result.srt_inverse
		end

	srt_inverse is
			-- inverses the matrix assuming it is a homogenous SRT transformation matrix.
		local
			a: EM_MATRIX44
			position:EM_VECTOR4D
			x_axis, y_axis, z_axis: EM_VECTOR3D
			x_scale, y_scale, z_scale: DOUBLE
		do
			a.set_row(row(1),1)
			a.set_row(row(2),2)
			a.set_row(row(3),3)
			a.set_row(row(4),4)

			x_axis.set(a.element(1,1), a.element(2,1), a.element(3,1))
			y_axis.set(a.element(1,2), a.element(2,2), a.element(3,2))
			z_axis.set(a.element(1,3), a.element(2,3), a.element(3,3))
			x_scale := x_axis.length
			y_scale := y_axis.length
			z_scale := z_axis.length

			position := -a.column(4)
			position.set_element (1,4)
			a.set_element(0.0,4,1)
			a.set_element(0.0,4,2)
			a.set_element(0.0,4,3)

			a.set_row(a.row(1)*(1/x_scale),1)
			a.set_row(a.row(2)*(1/y_scale),2)
			a.set_row(a.row(3)*(1/z_scale),3)

			a.transpose

			position := a.mult(position)

			a.set_row(a.row(1)*(1/x_scale),1)
			a.set_row(a.row(2)*(1/y_scale),2)
			a.set_row(a.row(3)*(1/z_scale),3)

			a.set_column(position,4)
			a.set_element(1,4,4)

			area := a.area
		end

	transpose is
			-- transposes the matrix
		local
		row1,row2,row3,row4 : EM_VECTOR4D
		do
			row1 := row(1)
			row2 := row(2)
			row3 := row(3)
			row4 := row(4)
			set_column(row1,1)
			set_column(row2,2)
			set_column(row3,3)
			set_column(row4,4)
		end


	det: DOUBLE is
			-- Calculate the determinant
		do
			result := element(1,1) * det3x3( element(2,2), element(2,3), element(2,4), element(3,2), element(3,3), element(3,4), element(4,2), element(4,3), element(4,4))
					- element(2,1) * det3x3( element(1,2), element(1,3), element(1,4), element(3,2), element(3,3), element(3,4), element(4,2), element(4,3), element(4,4))
					+ element(3,1) * det3x3( element(1,2), element(1,3), element(1,4), element(2,2), element(2,3), element(2,4), element(4,2), element(4,3), element(4,4))
					- element(4,1) * det3x3( element(1,2), element(1,3), element(1,4), element(2,2), element(2,3), element(2,4), element(3,2), element(3,3), element(3,4));
		end

feature {NONE} --Commands
	det2x2( a: DOUBLE; b: DOUBLE; c:DOUBLE; d: DOUBLE ):DOUBLE is
			-- Calculate the determinant of a 2x2 matrix
		do
			result := a*d - b*c
		end

	det3x3( a1: DOUBLE; a2: DOUBLE; a3: DOUBLE; b1: DOUBLE; b2: DOUBLE; b3: DOUBLE; c1:DOUBLE; c2:DOUBLE; c3:DOUBLE ):DOUBLE is
			-- Calculate the determinant of a 2x2 matrix
		do
			result := a1 * det2x2( b2, b3, c2, c3 )
        			- b1 * det2x2( a2, a3, c2, c3 )
        			+ c1 * det2x2( a2, a3, b2, b3 )
		end

feature -- Output

	out: STRING is
			-- Output the matrix to a string
		do
			Result := "! " + element(1,1).out + " 	 " + element(2,1).out + " 	 " + element(3,1).out + " 	 " + element(4,1).out + " !%N" +
					  "! " + element(1,2).out + " 	 " + element(2,2).out + " 	 " + element(3,2).out + " 	 " + element(4,2).out + " !%N" +
					  "! " + element(1,3).out + " 	 " + element(2,3).out + " 	 " + element(3,3).out + " 	 " + element(4,3).out + " !%N" +
					  "! " + element(1,4).out + " 	 " + element(2,4).out + " 	 " + element(3,4).out + " 	 " + element(4,4).out + " !%N"
		end


end
