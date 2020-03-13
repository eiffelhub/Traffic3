indexing
	description: "[
			A plane describes by a plane equation
		]"
	date: "$Date: Oct 15, 2006 4:36:44 PM$"
	revision: "$Revision: 1.0$"

expanded class EM_PLANE

inherit
	EM_PLANE_REF
	rename
		make as set,
		make_from_normal as set_from_normal,
		make_from_points as set_from_points
	export
		{ANY} set, set_from_normal, set_from_points, default_create
	end

create
	default_create,
	make_from_reference,
	make_from_tuple,
	make_from_tuplei,
	make_from_tuplef,
	make_from_normal_tuple,
	make_from_normal_tuplei,
	make_from_normal_tuplef,
	make_from_point_tuple,
	make_from_point_tuplei,
	make_from_point_tuplef

convert
	make_from_reference ({EM_PLANE_REF}),
	make_from_tuple ({TUPLE[DOUBLE, DOUBLE, DOUBLE, DOUBLE]}),
	make_from_tuplei ({TUPLE[INTEGER, INTEGER, INTEGER, INTEGER]}),
	make_from_tuplef ({TUPLE[REAL, REAL, REAL, REAL]}),
	make_from_normal_tuple ({TUPLE[EM_VECTOR3D,EM_VECTOR3D]}),
	make_from_normal_tuplei ({TUPLE[EM_VECTOR3I,EM_VECTOR3I]}),
	make_from_normal_tuplef ({TUPLE[EM_VECTOR3F,EM_VECTOR3F]}),
	make_from_point_tuple ({TUPLE[EM_VECTOR3D,EM_VECTOR3D,EM_VECTOR3D]}),
	make_from_point_tuplei ({TUPLE[EM_VECTOR3I,EM_VECTOR3I,EM_VECTOR3I]}),
	make_from_point_tuplef ({TUPLE[EM_VECTOR3F,EM_VECTOR3F,EM_VECTOR3F]})

end -- class EM_PLANE
