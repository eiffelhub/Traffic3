indexing
	description: "Objects that ..."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	TE_3D_RESSOURCE inherit

		GL_FUNCTIONS

		EM_GL_CONSTANTS

	create
		make

feature -- Initialization

	make (a_vertex_list: ARRAYED_LIST[EM_VECTOR3D]; a_normal_list: ARRAYED_LIST[EM_VECTOR3D]; a_face_list: ARRAYED_LIST[TE_3D_FACE]; some_uvw_sets:ARRAYED_LIST[ARRAYED_LIST[EM_VECTOR3D]]; a_cluster_list: ARRAYED_LIST[TE_3D_CLUSTER]) is
			-- create 3d ressource
		do
			cluster_list := a_cluster_list
			vertex_list := a_vertex_list
			normal_list := a_normal_list
			face_list := a_face_list
			uvw_sets := some_uvw_sets
			compile
		end


feature -- Access

	cluster_list: ARRAYED_LIST[TE_3D_CLUSTER] -- must contain >= 1 elements

	displaylist: INTEGER

	vertex_list: ARRAYED_LIST[EM_VECTOR3D]

	normal_list: ARRAYED_LIST[EM_VECTOR3D]

	face_list: ARRAYED_LIST[TE_3D_FACE]

	uvw_sets: ARRAYED_LIST[ARRAYED_LIST[EM_VECTOR3D]] --multiple uvw sets

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

feature {TE_3D_MEMBER} -- Implementation


	compile is
			-- create the displaylist - has to be called when a change in the internal mesh structure, the material or the shader shall take effect on the displayed object
		do
			gl_delete_lists(displaylist,1) -- if displaylist = 0 i.e. hasn't been defined yet, this command does have no effect

			displaylist := gl_gen_lists (1)
			gl_new_list (displaylist, EM_GL_COMPILE)
				specify
			gl_end_list
		end

	specify is
			-- send the meshdefinition to openGL
		local
			cluster: TE_3D_CLUSTER
			face: TE_3D_FACE
			i: INTEGER
			j: INTEGER
			normal, vertex, texcoord: EM_VECTOR3D
		do
			from --loop through all clusters
				cluster_list.start
			until
				cluster_list.after
			loop
				cluster := cluster_list.item

				from
					j := 1
				until
					j > cluster.material.material_passes
				loop

					cluster.material.specify_material_pass[j].publish([]) -- perform material_pass number j

					gl_begin (em_gl_triangles)
					from --loop through all faces of the cluster
						cluster.faces.start
					until
						cluster.faces.after
					loop
						face := face_list[cluster.faces.item]

						from -- loop trough all vertices of the face
							i := 1
						until
							i > face.vertices.count --3
						loop

							if face.normals /= Void and face.normals.count >= i then --specify normal for the next vertex
								normal := normal_list[face.normals[i]]
								gl_normal3d (normal.x, normal.y, normal.z)
							end
							if face.texture_coordinates[1] /= Void and face.texture_coordinates[1].count >= i then --specify texutre coordinates for the next vertex
								texcoord := uvw_sets[1].i_th(face.texture_coordinates[1].i_th(i)) --TODO: implement multiple uvw sets
								gl_tex_coord2d (texcoord.x, texcoord.y)
							end

							vertex := vertex_list[face.vertices[i]]
							gl_vertex3d (vertex.x, vertex.y, vertex.z) -- specify the vertex

							i := i+1
						end

						cluster.faces.forth
					end
					gl_end
					j := j + 1
				end --j
				cluster.material.remove -- pop attributes set by the material
				cluster_list.forth
			end --cluster_list
		end


	draw_geometry is
			-- calls the draw feature of the meshs
		do
			gl_call_list (displaylist)
		end

invariant
	invariant_clause: True -- Your invariant here

end
