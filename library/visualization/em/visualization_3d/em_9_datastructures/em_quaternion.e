indexing
	description: " A Quaternion is a replacement for retation-matrices. Its very fast and easy to interpolate, ... and can be transformed into a rotation matrix and vice versa "
	date: "$Date: 2006/10/17 22:27:36 $"
	revision: "$Revision: 1.5 $"

expanded class
	EM_QUATERNION

inherit
	EM_QUATERNION_REF
	rename
		make as set,
		make_from_rotation as set_from_rotation,
		make_from_matrix44 as set_from_matrix44,
		make_from_arc as set_from_arc
	end

create
	default_create,
	make_from_reference,
	make_from_tuple,
	make_from_vector_tuple,
	make_from_vector_ref_tuple,
	set_from_matrix44

convert
	make_from_reference ({EM_QUATERNION_REF}),
	make_from_tuple ({TUPLE[DOUBLE, DOUBLE, DOUBLE, DOUBLE]}),
	make_from_vector_ref_tuple ({TUPLE[EM_VECTOR3D_REF,DOUBLE]}),
	make_from_vector_tuple ({TUPLE[EM_VECTOR3D,DOUBLE]}),
	set_from_matrix44 ({EM_MATRIX44})

end
