indexing
	description: "Objects that ..."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	TE_3D_MEMBER_FACTORY


feature --Access

	last_3d_member: TE_3D_MEMBER


feature {NONE} -- Implementation

	cluster_list: ARRAYED_LIST[TE_3D_CLUSTER]

	vertex_list: ARRAYED_LIST[EM_VECTOR3D]

	normal_list: ARRAYED_LIST[EM_VECTOR3D]

	face_list: ARRAYED_LIST[TE_3D_FACE]

	uvw_sets: ARRAYED_LIST[ARRAYED_LIST[EM_VECTOR3D]]

	ressource_list : ARRAYED_LIST[TE_3D_RESSOURCE]

	shadow_ressource: TE_3D_RESSOURCE

	build_3d_member:TE_3D_MEMBER is
			-- builds the te_3d_member
		require
			ressource_list_not_void_and_not_empty: ressource_list /= Void and ressource_list.count > 0
		do
			create Result.make (ressource_list)
			if shadow_ressource /= Void then
				Result.set_shadow_ressource(shadow_ressource)
			end
			shadow_ressource := Void
		end

	build_3d_member_as_child(a_parent: TE_3D_NODE): TE_3D_MEMBER is
			-- builds the te_3d_member as child of a te_3D_node
		require
			ressource_list_not_void_and_not_empty: ressource_list /= Void and ressource_list.count > 0
			parent_not_void: a_parent /= void
		do
			create Result.make_as_child(ressource_list, a_parent)
			if shadow_ressource /= Void then
				Result.set_shadow_ressource(shadow_ressource)
			end
			shadow_ressource := Void
		end

	build_ressource_list is
			-- build the ressource list
		deferred
		end

	calculate_face_neighbours is
			-- loops through all faces and sets theyr neighbours - must be done for stencil shadows!
			-- TODO: algorithm has O(n^2) - could be improved (but it's not that important cause these things get calculated before runtime)
		local
			new_neighbour_array: ARRAY[INTEGER]
			current_face, face_to_compare: TE_3D_FACE
			i,j,e: INTEGER
			equal_vertices: ARRAYED_LIST[INTEGER] -- holds the indices of the common vertexes of both faces
		do
			from -- loop through all faces to set theyr neighbours
				i := 1
			until
				i > face_list.count
			loop
				current_face := face_list.i_th (i)
				create new_neighbour_array.make (0,2)
				from -- loop again through all faces to find faces that share two vertices with this face
					j:=1
				until
					j > face_list.count
				loop
					if i /= j then -- if the two faces to compare are different
						face_to_compare := face_list.i_th(j)
						create equal_vertices.make(0)
						from -- loop through all 3 vertex indices of current face
							e := 1
						until
							e > 3
						loop
							if face_to_compare.vertices.has (current_face.vertices.i_th(e)) then -- if the vertex index is in the vertex indieces list of the seround face too
								equal_vertices.extend (e) -- the 'e'TH vertex of the face is shared with the other face
							end
							e := e+1
						end
						if equal_vertices.count = 2 then -- if the two faces share one edge
							if equal_vertices.has(1) and equal_vertices.has(2) then -- it's the first edge
								new_neighbour_array.force (j,0) --put the index of the compare_face at the first edge (0)
							elseif equal_vertices.has(2) and equal_vertices.has (3) then -- it's the secound edge
								new_neighbour_array.force (j,1) --put the index of the compare_face at the secound edge (1)
							elseif equal_vertices.has (3) and equal_vertices.has (1) then -- it's the third edge
								new_neighbour_array.force (j,2) --put the index of the compare_face at the third edge (2)	
							else
								io.put_string("ERROR! faces have two equal vertices but they're not in the vertex_list at position 1,2 or 3! %N")
							end
						end
					end -- i/=j
					j := j+1
				end
				current_face.set_neighbour_faces(new_neighbour_array)
				i := i+1
			end
		end


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

feature -- Obsolete

feature -- Inapplicable

invariant
	invariant_clause: True -- Your invariant here

end
