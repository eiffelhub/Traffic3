indexing
	description: "Objects that ..."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	TE_3D_MEMBER_FACTORY_FROMFILE_OBJ inherit
	--TODO: extend for LOD
	--TODO: readface: possibility for faces with texturecoordinates/normals and faces without

		TE_3D_MEMBER_FACTORY_FROMFILE


feature -- Status setting

	enable_shadowvolume_calculation is
			-- all subsequent models will be processed for shadowvolume creation
		do
			shadowvolume_calculation := true
		end

	disable_shadowvolume_calculation is
			-- all subsequent models won't be processed for shadowvolume creation
		do
			shadowvolume_calculation := false
		end

	shadowvolume_calculation : BOOLEAN


feature -- 3D Member Creation

	create_3d_member_from_file(a_filename:STRING) is
			-- creates 3d member from an obj file
		require else
			must_be_obj: a_filename.substring (a_filename.count - 2, a_filename.count).is_equal ("obj")
		do
			load_obj_file(a_filename, shadowvolume_calculation)
			build_ressource_list
			last_3d_member := build_3D_member
		end


feature {NONE} -- Ressource List Creation

	build_ressource_list is
			-- builds the ressource list from which the 3d member gets built
		require else
			cluster_list_not_void_nor_empty: cluster_list /= Void and cluster_list.count > 0
			vertex_list_not_void_nor_empty: vertex_list /= Void and vertex_list.count > 2
			face_list_not_void_nor_empty: face_list /= Void and face_list.count > 0
		local
			first_ressource: TE_3D_RESSOURCE
		do
			create ressource_list.make(0)
			create first_ressource.make (vertex_list, normal_list, face_list, uvw_sets, cluster_list)
			ressource_list.extend(first_ressource)
		end


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

feature {NONE} -- Implementation

	has_texture_coordinates: BOOLEAN

	has_normals: BOOLEAN

	load_obj_file(a_filename:STRING; calc_shadow_volume: BOOLEAN)
			--loads the obj file information
			--TODO: currently, the path of the obj file gets extracted from the filename string to find the path for the mtl file. Maybe there's a better way to do so...
		require
			must_be_obj: a_filename.substring (a_filename.count - 2, a_filename.count).is_equal ("obj")
		local
			obj_file: PLAIN_TEXT_FILE
			tokenizer: TE_3D_TEXT_SCANNER
			current_uvw_set: ARRAYED_LIST[EM_VECTOR3D]
			first_cluster: TE_3D_CLUSTER
			current_cluster: INTEGER
			face_count: INTEGER
			poly_to_triangle_list: LINKED_LIST[TE_3D_FACE]
			face_indices: LINKED_LIST[INTEGER]
			mtl_factory: TE_MATERIAL_FACTORY_MTL
			shadow_factory: TE_3D_MEMBER_FACTORY_FROMFILE_OBJ
			path_name: STRING
			current_texture_coordinates: EM_VECTOR3D
			counter: INTEGER
		do
			-- DEBUG
				io.put_string("load file: " + a_filename +"%N")
			--/DEBUG


			create vertex_list.make(0)
			create normal_list.make(0)
			create face_list.make(0)
			create face_indices.make
			create uvw_sets.make(0)
			create current_uvw_set.make(0)

			create cluster_list.make(1)
			create first_cluster.make_with_default_material
			cluster_list.force(first_cluster)
			current_cluster := 1

			from
				create obj_file.make_open_read (a_filename)
				create tokenizer.make_from_string_with_delimiters ("", " %T")
				face_count := 1
			until
				obj_file.after
			loop
				obj_file.read_line

				--STATUSPUNKTE
				if (obj_file.position)/(obj_file.count) > 0.1 * counter then
					io.put_string (".")
					counter := counter + 1
					if counter = 10 then
						io.new_line
					end
				end
				--/STATUSPUNKTE

				if not obj_file.last_string.is_empty then
					tokenizer.set_source_string (obj_file.last_string)

					-- set the iterator
					tokenizer.read_token

					if  tokenizer.last_string.is_equal ("mtllib") then
						--extract pathname from filename string
						path_name := a_filename.substring(1, a_filename.last_index_of('\', a_filename.count))
						--load material_library
						tokenizer.read_token
						path_name := path_name + tokenizer.last_string
						create mtl_factory.make
						mtl_factory.create_material_list_from_file(path_name)
						--set material of first_cluster to the first material of the loaded materiallist
						cluster_list[1].set_material(mtl_factory.last_material_list[1])
						--create additional clusters if there are more than 1 material defined in the mtllib and assign the corresponding materials to the clusters
						from
							mtl_factory.last_material_list.start
							mtl_factory.last_material_list.forth
						until
							mtl_factory.last_material_list.after
						loop
							cluster_list.extend(create{TE_3D_CLUSTER}.make(mtl_factory.last_material_list.item))
							mtl_factory.last_material_list.forth
						end
					elseif tokenizer.last_string.is_equal ("shadow") then
						--load a shadow ressource
						path_name := a_filename.substring(1, a_filename.last_index_of('\', a_filename.count))
						tokenizer.read_token
						path_name := path_name + tokenizer.last_string
						create shadow_factory
						shadow_factory.create_3d_member_from_file(path_name)
						shadow_ressource := shadow_factory.last_3d_member.ressource_list.i_th(1)
					elseif tokenizer.last_string.is_equal ("#") then
						-- ignore this line, it's a comment
					elseif tokenizer.last_string.is_equal ("v") then
						-- read a vertex:
						tokenizer.read_token
						vertex_list.force (read_vector (tokenizer))
					elseif tokenizer.last_string.is_equal ("vn") then
						-- read a normal vector:
						tokenizer.read_token
						normal_list.force (read_vector(tokenizer))
						has_normals := true
					elseif tokenizer.last_string.is_equal ("vt") then
						-- read a texture vector:
						tokenizer.read_token
						current_texture_coordinates := read_vector(tokenizer)
						current_texture_coordinates.set_y(1.0-current_texture_coordinates.y) -- FLIP THE TEXTURE UV IN V DIRECTION
						current_uvw_set.force (current_texture_coordinates)
						has_texture_coordinates := true
					elseif tokenizer.last_string.is_equal ("usemtl") then
						--next face will be part of cluster with materialdefinition after usemtl keyword. Set current_cluster to corresponding clusterindex
						tokenizer.read_token
						current_cluster := mtl_factory.last_nametable.item(tokenizer.last_string)
					elseif tokenizer.last_string.is_equal ("f")  then
						-- read a face:
						tokenizer.read_token
						poly_to_triangle_list := read_polygon(tokenizer)
						from -- loop trough all triangles of the read polygon
							poly_to_triangle_list.start
						until
							poly_to_triangle_list.after
						loop
							face_list.force(poly_to_triangle_list.item)
							cluster_list[current_cluster].push_index(face_count)
							face_count := face_count + 1
							poly_to_triangle_list.forth
						end
					else
						-- ignore this line, since I can't use it
					end
				end
			end
			if calc_shadow_volume then
				calculate_face_neighbours -- loop through all faces to set the neighbour lists for each face for stencil shadows
			end
			uvw_sets.force(current_uvw_set)
		end


	read_vector (tokenizer: TE_3D_TEXT_SCANNER): EM_VECTOR3D is
			-- Read the vertex data from the current position
		local
			i: INTEGER
			double_array: ARRAY[DOUBLE]
		do
			create double_array.make(0,2)

			from
				i := 0
			until
				i > 2
			loop
				if tokenizer.last_string.is_double then
					double_array.force (tokenizer.last_string.to_double, i)
				else
					double_array.force (0.0, i)
				end
				tokenizer.read_token
				i := i + 1
			end
			Result.set(double_array.item(0), double_array.item(1), double_array.item(2))
		end


	read_polygon (input_tokenizer: TE_3D_TEXT_SCANNER): LINKED_LIST[TE_3D_FACE] is
			-- Read the face data from the current position
		local
			polygon_vertex_indices: ARRAYED_LIST[INTEGER]
			polygon_normal_indices: ARRAYED_LIST[INTEGER]
			polygon_uvw_indices: ARRAYED_LIST[INTEGER]
			triangle_vertex_indices: ARRAYED_LIST[INTEGER]
			triangle_normal_indices: ARRAYED_LIST[INTEGER]
			triangle_uvw_indices: ARRAYED_LIST[INTEGER]
			new_uvw_sets: ARRAYED_LIST[ARRAYED_LIST[INTEGER]]
			i: INTEGER
			current_face: TE_3D_FACE
			current_value: STRING
			token: STRING
			slash_index:INTEGER
		do
			create Result.make

			create polygon_vertex_indices.make(0)
			create polygon_normal_indices.make(0)
			create polygon_uvw_indices.make(0)

			from

			until
				input_tokenizer.last_string.is_equal ("")
			loop
				token := input_tokenizer.last_string
				slash_index := token.index_of ('/',1)
				current_value := token.substring(1, slash_index-1)
				if not current_value.is_equal ("") then
					polygon_vertex_indices.force (current_value.to_integer)
				end
				current_value := token.substring(slash_index+1,token.index_of ('/', slash_index+1)-1)
				if slash_index /= 0 then
					slash_index := token.index_of ('/', slash_index+1)
				else
					current_value := ""
				end
				if not current_value.is_equal ("") and has_texture_coordinates then
					polygon_uvw_indices.force (current_value.to_integer)
				end
				if slash_index /= 0 then
					current_value := token.substring (slash_index+1,token.count)
				else
					current_value := ""
				end
				if not current_value.is_equal ("") and has_normals then
					polygon_normal_indices.force (current_value.to_integer)
				end

				input_tokenizer.read_token
			end

			--decomposite to triangles --works only with convex polygons!!
			from
				i := 2
			until
				i > polygon_vertex_indices.count - 1
			loop
				create triangle_vertex_indices.make(0)
				create triangle_normal_indices.make(0)
				create triangle_uvw_indices.make(0)

				triangle_vertex_indices.force (polygon_vertex_indices.i_th (1))
				triangle_vertex_indices.force (polygon_vertex_indices.i_th (i))
				triangle_vertex_indices.force (polygon_vertex_indices.i_th (i+1))

				if polygon_normal_indices.count /= 0 then
					triangle_normal_indices.force (polygon_normal_indices.i_th (1))
					triangle_normal_indices.force (polygon_normal_indices.i_th (i))
					triangle_normal_indices.force (polygon_normal_indices.i_th (i+1))
				end

				if polygon_uvw_indices.count /= 0 then
					triangle_uvw_indices.force (polygon_uvw_indices.i_th (1))
					triangle_uvw_indices.force (polygon_uvw_indices.i_th (i))
					triangle_uvw_indices.force (polygon_uvw_indices.i_th (i+1))
				end

				create new_uvw_sets.make(0)
				new_uvw_sets.force(triangle_uvw_indices)
				create current_face.make(triangle_vertex_indices, triangle_normal_indices, new_uvw_sets, vertex_list.i_th (triangle_vertex_indices.i_th (1)),vertex_list.i_th (triangle_vertex_indices.i_th (2)),vertex_list.i_th (triangle_vertex_indices.i_th (3)))
				Result.extend(current_face)

				i := i+1
			end
		end


invariant
	invariant_clause: True -- Your invariant here

end
