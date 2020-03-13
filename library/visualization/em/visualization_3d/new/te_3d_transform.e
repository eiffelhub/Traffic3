
indexing
	description: "Objects that ..."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	TE_3D_TRANSFORM

create
	make, make_from_matrix


feature -- initialization

	make is
			-- Initialize with default values
		do
			model_matrix.set_unit
			scaling.set (1,1,1)
			create event_channel
		end

	make_from_matrix(a_matrix: EM_MATRIX44) is
				-- make transform object from transformation matrix
		do
			model_matrix := a_matrix
			scaling.set(1,1,1) --TODO: this is wrong! find out how to extract the scaling!!
			create event_channel
		end


feature -- Access

	position: EM_VECTOR3D is
		-- position
		do
			result.set(model_matrix.element (1,4), model_matrix.element (2,4), model_matrix.element (3,4))
		end

	rotation: EM_QUATERNION is
			-- rotation as quaternion
		do
			Result.set_from_matrix44(model_matrix)
		end

	scaling: EM_VECTOR3D

	x_axis: EM_VECTOR3D
		-- x_axis
		do
			Result.set(model_matrix.element(1,1),model_matrix.element(2,1),model_matrix.element(3,1))
			Result.normalize
		end

	y_axis: EM_VECTOR3D
		-- y_axis
		do
			Result.set(model_matrix.element(1,2),model_matrix.element(2,2),model_matrix.element(3,2))
			Result.normalize
		end

	z_axis: EM_VECTOR3D
		-- z_axis
		do
			Result.set(model_matrix.element(1,3),model_matrix.element(2,3),model_matrix.element(3,3))
			Result.normalize
		end

	model_matrix: EM_MATRIX44
			-- transform matrix of the object


feature -- Measurement

feature -- Status report

feature -- Status setting

feature -- Cursor movement

feature -- Element change

feature -- Removal

feature -- Resizing

feature -- Transformation

	reset is
			-- resets the transformation
		do
			model_matrix.set_unit
		end


	set_position(x,y,z:DOUBLE) is
		-- sets the position
		do
			model_matrix.set_element(x,1,4)
			model_matrix.set_element(y,2,4)
			model_matrix.set_element(z,3,4)
			event_channel.publish([])
		end

	set_rotation(x,y,z,alpha:DOUBLE) is
			-- sets the rotation from default arraund the axis specified with xyz about the angle alpha
		local
			S,R,T:EM_MATRIX44
			rotation_axis: EM_VECTOR3D
			scale_vec: EM_VECTOR4D
		do
			rotation_axis.set(x,y,z)
			scale_vec.set(scaling.x,scaling.y,scaling.z,1.0)
			S.set_diagonal (scale_vec)
			T.set_from_translation (position)
			R.set_from_rotation (rotation_axis, alpha)
			model_matrix := T * R * S
			event_channel.publish([])
		end

	set_scaling(x,y,z:DOUBLE) is
			-- sets the scaling
		do
			model_matrix.set_column(model_matrix.column(1)*(x/scaling.x),1)
			model_matrix.set_column(model_matrix.column(2)*(y/scaling.y),2)
			model_matrix.set_column(model_matrix.column(3)*(z/scaling.z),3)
			scaling.set(x,y,z)
			event_channel.publish([])
		end


	translate (x,y,z:DOUBLE) is
			-- offsets the position with the translate-vector
		local
			translation_vect: EM_VECTOR3D
			translation: EM_MATRIX44
		do
			translation_vect.set(x,y,z)
			translation.set_from_translation(translation_vect)
			model_matrix := translation * model_matrix
			event_channel.publish([])
		end

	rotate (x,y,z,alpha:DOUBLE) is
			-- rotates arround the axis specified with xyz about the angle alpha
		local
			direction_vect: EM_VECTOR3D
			rot_mat:EM_MATRIX44
		do
			direction_vect.set(x,y,z)
			rot_mat.set_from_rotation(direction_vect, alpha)
			model_matrix :=model_matrix * rot_mat
			event_channel.publish([])
		end

	set_model_matrix (new_model_matrix: EM_MATRIX44) is
			-- sets the model matrix. the event_channel does NOT get called!!
		do
			model_matrix := new_model_matrix
			scaling.set(1,1,1) --TODO: this is wrong! find out how to extract the scaling!!
		end

feature -- Conversion

	to_opengl: POINTER is
			-- for passing the transform object to openGL
		do
			Result := model_matrix.to_pointer
		end


feature -- Duplication

feature -- Miscellaneous

feature -- Basic operations

	infix "*" (other: like Current): like Current is
			-- creates a transform object containing the transformation from both transform objects
		do
			create Result.make_from_matrix(model_matrix * other.model_matrix)
		end

	vectortransform (a_vector: EM_VECTOR3D): EM_VECTOR3D is
			-- transforms the vector
		local
			homogenous_vector: EM_VECTOR4D
		do
			homogenous_vector.set(a_vector.x, a_vector.y, a_vector.z, 1.0)
			homogenous_vector := model_matrix.mult(homogenous_vector)
			Result.set (homogenous_vector.x, homogenous_vector.y, homogenous_vector.z)
		end

	inverse_vectortransform (a_vector: EM_VECTOR3D): EM_VECTOR3D is
			--transforms the vector by a inverse of the transform object
		local
			homogenous_vector: EM_VECTOR4D
		do
			homogenous_vector.set(a_vector.x, a_vector.y, a_vector.z, 1.0)
			homogenous_vector := model_matrix.srt_inversed.mult(homogenous_vector)
			Result.set (homogenous_vector.x, homogenous_vector.y, homogenous_vector.z)
		end

feature -- Obsolete

feature -- Inapplicable

feature -- Implementation

	event_channel: EM_EVENT_CHANNEL[TUPLE[]]

invariant
	invariant_clause: True -- Your invariant here

end
