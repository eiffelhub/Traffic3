indexing
	description: "Objects that ..."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	TE_3D_MEMBER_FACTORY_PRIMITIVE inherit
	--TODO: extend for LOD
	--TODO: readface: possibility for faces with texturecoordinates/normals and faces without

		TE_3D_MEMBER_FACTORY

	create
		make

feature -- Initialization

	make is
			-- create factory and set material to default_material
		do
			set_material((create{TE_3D_SHARED_GLOBALS}).default_material)
		end

feature -- Access

	material: TE_MATERIAL

feature -- 3D Member Creation

	create_simple_plane(u_length,v_length:DOUBLE) is
			-- creates 3d member from an obj file
		require else
			length_positive: u_length > 0.0 and v_length > 0.0
		local
			current_uvw_set: ARRAYED_LIST[EM_VECTOR3D]
			new_uvw_index_set: ARRAYED_LIST[ARRAYED_LIST[INTEGER]]
			vector: EM_VECTOR3D
			vertex_indices, normal_indices, uvw_indices: ARRAYED_LIST[INTEGER]
			current_face: TE_3D_FACE
			single_cluster: TE_3D_CLUSTER
		do
			create vertex_list.make(4)
			create normal_list.make(1)
			create face_list.make(1)
			create uvw_sets.make(1)
			create current_uvw_set.make(4)
			create new_uvw_index_set.make(1)

			create vertex_indices.make(3)
			create normal_indices.make(3)
			create uvw_indices.make(3)

			--create vertices
			vector.set(-u_length/2.0,0.0,-v_length/2.0)
			vertex_list.force(vector)
			vector.set(-u_length/2.0,0.0,v_length/2.0)
			vertex_list.force(vector)
			vector.set(u_length/2.0,0.0,v_length/2.0)
			vertex_list.force(vector)
			vector.set(u_length/2.0,0.0,-v_length/2.0)
			vertex_list.force(vector)



			--create uv coordinates
			vector.set(0.0,1.0,0.0)
			current_uvw_set.force(vector)
			vector.set(0.0,0.0,0.0)
			current_uvw_set.force(vector)
			vector.set(1.0,0.0,0.0)
			current_uvw_set.force(vector)
			vector.set(1.0,1.0,0.0)
			current_uvw_set.force(vector)
			uvw_sets.force(current_uvw_set)

			--create normal
			vector.set(0.0,1.0,0.0)
			normal_list.force(vector)

			--create first face
			vertex_indices.force(1)
			vertex_indices.force(2)
			vertex_indices.force(3)

			normal_indices.force(1)
			normal_indices.force(1)
			normal_indices.force(1)

			uvw_indices.force(1)
			uvw_indices.force(2)
			uvw_indices.force(3)

			new_uvw_index_set.force(uvw_indices)

			create current_face.make(vertex_indices, normal_indices,new_uvw_index_set, vertex_list.i_th (vertex_indices.i_th(1)),vertex_list.i_th (vertex_indices.i_th(2)),vertex_list.i_th (vertex_indices.i_th(3)))
			face_list.force(current_face)

			--create secound face
			create new_uvw_index_set.make(1)
			create vertex_indices.make(3)
			create normal_indices.make(3)
			create uvw_indices.make(3)

			vertex_indices.force(1)
			vertex_indices.force(3)
			vertex_indices.force(4)

			normal_indices.force(1)
			normal_indices.force(1)
			normal_indices.force(1)

			uvw_indices.force(1)
			uvw_indices.force(3)
			uvw_indices.force(4)

			new_uvw_index_set.force(uvw_indices)

			create current_face.make(vertex_indices, normal_indices,new_uvw_index_set,vertex_list.i_th (vertex_indices.i_th(1)),vertex_list.i_th (vertex_indices.i_th(2)),vertex_list.i_th (vertex_indices.i_th(3)))
			face_list.force(current_face)

			--create cluster
			create cluster_list.make(1)
			create single_cluster.make(material)
			single_cluster.push_index (1)
			single_cluster.push_index (2)
			cluster_list.force(single_cluster)

			calculate_face_neighbours
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


feature -- Basic operations

	set_material(a_material: TE_MATERIAL) is
			-- sets the material for the next primitive to be created
		do
			material := a_material
		end

end
