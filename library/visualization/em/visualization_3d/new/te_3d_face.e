indexing
	description: "Objects that ..."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	TE_3D_FACE inherit

		DOUBLE_MATH

	create
		make

feature -- initialisation

	make(some_vertices, some_normals: ARRAYED_LIST[INTEGER];some_texture_coordinates: ARRAYED_LIST[ARRAYED_LIST[INTEGER]];point_a, point_b, point_c: EM_VECTOR3D) is
			-- creates the face - point_a, point_b and point_c are the actual vertex positions in objectspace. needed to calculate the face_normal and the face_plane
		require
			vertices_3: some_vertices.count = 3
		do
			vertices := some_vertices
			normals := some_normals
			texture_coordinates := some_texture_coordinates
			face_plane.set_from_points(point_a, point_b, point_c)
			face_normal := face_plane.normal
		end


feature -- Access

	vertices: ARRAYED_LIST[INTEGER] -- must contain 3 elements

	normals: ARRAYED_LIST[INTEGER] -- must contain 3 elements

	texture_coordinates: ARRAYED_LIST[ARRAYED_LIST[INTEGER]] -- each element in Arrayed_list must contain 3 elements

	face_normal: EM_VECTOR3D -- face normal in objectspace

	face_plane: EM_PLANE -- plane in which the face lies in objectspace. needed to calculate stencil shadows

	neighbour_faces: ARRAY[INTEGER] -- position 0 is neighbour at edge [1,2], 1 is at edge [2,3], 2 is at edge[3,1] -- if the value is 0, then the face has no neighbour at this edge (border!)

	is_lit: BOOLEAN
		-- reports wether the face is lit by the shadow casting lightsource. must be calculated first by calculate_face_lit

feature -- Measurement

feature -- Status report

feature -- Status setting

feature -- Cursor movement

feature -- Element change

feature -- Removal

feature -- Resizing

feature -- Transformation

feature -- Conversion

feature -- Duplication

feature -- Miscellaneous

feature -- Basic operations

	calculate_face_lit(light_position: EM_VECTOR3D) is
			-- calculates wether the face is lit by the lightsource. LIGHTPOSITION MUST BE PASSED IN OBJECTSPACE!!
--		local
--			angle: DOUBLE
		do
			--angle := arc_cosine(face_normal.dot_product (light_position)/(face_normal.length * light_position.length))
			--is_lit := angle <= PI/2.0
			is_lit := face_plane.is_point_above(light_position)
		end

	set_neighbour_faces (some_neighbour_faces: ARRAY[INTEGER]) is
			-- sets the neighbour faces needed for stencil shadows
		require
			array_right_size: some_neighbour_faces.lower = 0 and some_neighbour_faces.upper = 2
		do
			neighbour_faces := some_neighbour_faces
		end

feature -- Obsolete

feature -- Inapplicable

feature {NONE} -- Implementation

invariant
	invariant_clause: True -- Your invariant here

end
