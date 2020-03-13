indexing
	description: "Objects that ..."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	TE_3D_SHADOW_VOLUME inherit

		GL_FUNCTIONS export {NONE} all end

		EM_GL_CONSTANTS export {NONE} all end

	create
		make

feature -- Initialization

	make is
			-- creates the shadow_volume
		do
			create shadow_quads.make
			create unlit_faces.make
		end


feature -- Access

	shadow_quads: LINKED_LIST[LINKED_LIST[EM_VECTOR3D]] -- list of quads containing 4 3dvector

	vertex_array: ARRAY[DOUBLE] -- array storing the shadowvolume as vertex array of quads

	unlit_faces: LINKED_LIST[TE_3D_FACE]
		--stores faces of the used 3d_ressource which are not lit by the shadow casting light source

	corresponding_3d_ressource: TE_3D_RESSOURCE
		--stores the 3d_ressource from which the shadow volume got calculated

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

	update_shadow_volume(a_light_position: EM_VECTOR3D; is_direct_light: BOOLEAN; a_3d_ressource: TE_3D_RESSOURCE)is
			-- calculates the shadow volume given a certain 3d_ressource and light vector. a_light_position must be in object space and is_direct_light tells wether an openGL infinite light is used or not
			-- if is_direct_light is true, the light_position must be the directional vector to infiniti thorwards the lightsource in object_space
		require
			ressource_exists: a_3d_ressource /= Void
		local
			lit_faces: LINKED_LIST[TE_3D_FACE]
			p1,p2,p3,p4: EM_VECTOR3D
			light_vector: EM_VECTOR3D
			i:INTEGER
			face_list: ARRAYED_LIST[TE_3D_FACE]
			vertex_list: ARRAYED_LIST[EM_VECTOR3D]
			vac: INTEGER -- vertex_array_counter
		do
			--create shadow_quads.make
			create unlit_faces.make
			create lit_faces.make

			corresponding_3d_ressource := a_3d_ressource
			face_list := a_3d_ressource.face_list
			vertex_list := a_3d_ressource.vertex_list

			from -- loop through all faces and calculate whether they're lit. add the lit faces to the lit_faces list
				face_list.start
			until
				face_list.after
			loop
				face_list.item.calculate_face_lit (a_light_position)
				if face_list.item.is_lit then
					lit_faces.extend (face_list.item)
				else
					unlit_faces.extend (face_list.item)
				end
				face_list.forth
			end

			create vertex_array.make(0,lit_faces.count*36)


			light_vector := -a_light_position.normalized -- this is used if the light is directional

			from -- loop through all lit faces and check, wether the edge of the faces are shadowedges
				lit_faces.start
			until
				lit_faces.after
			loop
				from -- loop through all 3 neighbours of the current lit face
					i := 0
				until
					i > 2
				loop
					if lit_faces.item.neighbour_faces.item(i) = 0 or else face_list.i_th(lit_faces.item.neighbour_faces.item(i)).is_lit=false then -- if the current face has at the iTH edge no neighbour or a not lit one
						--calculate shadowprojected quad
						p1 := vertex_list.i_th (lit_faces.item.vertices.i_th((i+1)\\3+1))
						p2 := vertex_list.i_th (lit_faces.item.vertices.i_th(i+1))
						if is_direct_light then
							p3 := p2 + light_vector * 10
							p4 := p1 + light_vector * 10
						else
							light_vector := (p2-a_light_position).normalized -- TODO: costly calculation : normalized - improve this when implementing shadow clipping!
							p3 := p2 + light_vector * 10 -- TODO: hardcoded shadow volume lenght!
							light_vector := (p1-a_light_position).normalized
							p4 := p1 + light_vector * 10
						end
						--push the values to the vertex array as two independant triangles
						vertex_array.put(p1.x,vac); vac := vac+1; vertex_array.put(p1.y,vac); vac := vac+1; vertex_array.put(p1.z,vac); vac := vac+1
						vertex_array.put(p2.x,vac); vac := vac+1; vertex_array.put(p2.y,vac); vac := vac+1; vertex_array.put(p2.z,vac); vac := vac+1
						vertex_array.put(p3.x,vac); vac := vac+1; vertex_array.put(p3.y,vac); vac := vac+1; vertex_array.put(p3.z,vac); vac := vac+1
						vertex_array.put(p4.x,vac); vac := vac+1; vertex_array.put(p4.y,vac); vac := vac+1; vertex_array.put(p4.z,vac); vac := vac+1
					end
					i:=i+1
				end
				lit_faces.forth
			end
		end



	draw_shadow_volume is
			-- calculates and draws the shadow volume casted at a_light_position. This position must be in object space!
		local
			c_array: ANY
		do
			c_array := vertex_array.to_c
			gl_vertex_pointer(3,em_GL_DOUBLE,0,$c_array)
			gl_draw_arrays(em_GL_QUADS,0,vertex_array.count//3)
		end

	draw_unlit_faces is
			-- draws the unlit faces
		local
			p1,p2,p3: EM_VECTOR3D
			vertex_list: ARRAYED_LIST[EM_VECTOR3D]
		do
			gl_begin(em_gl_triangles)
			from
				unlit_faces.start
			until
				unlit_faces.after
			loop
				vertex_list := corresponding_3d_ressource.vertex_list
				p1 := vertex_list.i_th(unlit_faces.item.vertices.i_th(1))
				p2 := vertex_list.i_th(unlit_faces.item.vertices.i_th(2))
				p3 := vertex_list.i_th(unlit_faces.item.vertices.i_th(3))

					gl_vertex3d(p1.x,p1.y,p1.z)
					gl_vertex3d(p2.x,p2.y,p2.z)
					gl_vertex3d(p3.x,p3.y,p3.z)

				unlit_faces.forth
			end
			gl_end
		end


feature -- Obsolete

feature -- Inapplicable

feature {NONE} -- Implementation

invariant
	invariant_clause: True -- Your invariant here

end
