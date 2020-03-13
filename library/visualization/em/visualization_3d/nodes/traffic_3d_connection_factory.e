indexing
	description: "Objects that ..."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	TRAFFIC_3D_CONNECTION_FACTORY inherit

		TE_3D_MEMBER_FACTORY_PRIMITIVE
			redefine
				make
			end

		TRAFFIC_CONSTANTS

		DOUBLE_MATH

create make

feature -- Initialization

	make is
			-- Initialize the factory and set the material to a white material.
		local
			default_material: TE_MATERIAL_SIMPLE
		do
			create default_material.make_with_color(1.0,1.0,1.0)
			set_material(default_material)
			width := Line_width
		end

feature -- Access

	width: DOUBLE
			-- Width of line that represents the connection

feature -- Status setting

	set_color (r,g,b: DOUBLE) is
			-- Set `color' to `a_color'. as unclamped floating point colors
		local
			new_material: TE_MATERIAL_SIMPLE
		do
			create new_material.make_with_color(r, g, b)
			set_material(new_material)
		end

	set_width (a_width: DOUBLE) is
			-- Set the `width' of the drawn connection to `a_width'.
		require
			width_valid: a_width > 0.0
		do
			width := a_width
		end

feature -- Basic operations

	new_connection (a_connection: TRAFFIC_CONNECTION): TRAFFIC_3D_RENDERABLE [TRAFFIC_CONNECTION] is
			-- New polyline for `a_connection'
		require
			width_positive: width > 0
			connection_not_void: a_connection /= void
		local
			polyline_3d: ARRAYED_LIST[EM_VECTOR3D]
			current_polypoint_3d: EM_VECTOR3D
			p1: EM_VECTOR3D
			q1, q2: EM_VECTOR3D
			i: INTEGER
		do
			create polyline_3d.make(a_connection.polypoints.count)

			-- Case 1: There are only 2 polypoints. Check if they are the same.
			if a_connection.polypoints.count = 2 then
				if a_connection.polypoints.item (1).distance (a_connection.polypoints.item (2)) > 0.0 then
					current_polypoint_3d.set (a_connection.polypoints.item (1).x, 0.0, a_connection.polypoints.item (1).y)
					polyline_3d.extend (current_polypoint_3d)
					current_polypoint_3d.set (a_connection.polypoints.item (2).x, 0.0, a_connection.polypoints.item (2).y)
					polyline_3d.extend (current_polypoint_3d)
				end
			-- Case 2: There are more than 2 polypoints. Check angles between consecutive segments.
			else
				from
					i := 2
					p1.set (a_connection.polypoints.item (1).x, 0.0, a_connection.polypoints.item (1).y)
					polyline_3d.extend (p1)
				until
					i > a_connection.polypoints.count
				loop
					if polyline_3d.count < 2 then
						-- Check length
						p1.set (a_connection.polypoints.item (i).x, 0.0, a_connection.polypoints.item (i).y)
						if (p1-polyline_3d.last).length > 0.0 then
							polyline_3d.extend (p1)
						end
					else
						-- Check angle
						p1.set (a_connection.polypoints.item (i).x, 0.0, a_connection.polypoints.item (i).y)
						q1 := polyline_3d.i_th (polyline_3d.count - 1) - polyline_3d.last
						q2 := p1 - polyline_3d.last
						if angle_between_vectors (q1, q2) >= 0.000001 or angle_between_vectors (q1, q2) <= -0.000001 then
							polyline_3d.extend (p1)
						end
					end
					i := i + 1
				end

			end
--			p := a_connection.polypoints.first
----			create current_polypoint_3d.make_from_tuple ([a_connection.polypoints.first.x, 0.0, a_connection.polypoints.first.y])
--			current_polypoint_3d.set (p.x, 0.0, p.y)
--			polyline_3d.force (current_polypoint_3d)
--			from
--				i := 2
--			until
--				i > a_connection.polypoints.count
--			loop
--				if p.distance (a_connection.polypoints.item (i)) > 0.0 then
--					p := a_connection.polypoints.item (i)
--					current_polypoint_3d.set (p.x, 0.0, p.y)
--					polyline_3d.extend (current_polypoint_3d)
--				end
--				i := i + 1
--			end
			-- Add last point to the 3d_polyline
--			i := a_connection.polypoints.count - 1
--			if a_connection.polypoints.item (i).distance (a_connection.polypoints.item (i+1)) > 0.0 then
--				current_polypoint_3d.set (a_connection.polypoints.item (i+1).x, 0.0, a_connection.polypoints.item (i+1).y)
--				polyline_3d.extend (current_polypoint_3d)
--			end
			if polyline_3d.count >= 2 then
				create_flat_polyline(polyline_3d, width)
				create Result.make (a_connection)
				Result.add_child (last_3d_member)
			else
				create Result.make (a_connection)
				Result.add_child (create {TE_3D_NODE}.make)
			end
		ensure
			Result_exists: Result /= Void
		end

feature {NONE} -- Implementation

	angle_between_vectors(vector_a, vector_b: EM_VECTOR3D): DOUBLE is
			-- Angle between two 3d vectors
		local
			d,l,a: DOUBLE
		do
			l := (vector_a.length * vector_b.length)
			d := (vector_a.dot_product(vector_b))
			a := d/l
			if a < -1.0 then
				a := -1.0
			elseif a > 1.0 then
				a := 1.0
			end
			Result := arc_cosine(a)
		end

	create_flat_polyline(some_points: ARRAYED_LIST[EM_VECTOR3D]; a_width: DOUBLE) is
			-- creates polyline facing torwards the y value
		require
			at_least_one_segment: some_points.count >= 2
		local
			current_uvw_set: ARRAYED_LIST[EM_VECTOR3D]
			new_uvw_index_set: ARRAYED_LIST[ARRAYED_LIST[INTEGER]]
			vector, current_point, next_point, last_point, current_bisector, up_vector: EM_VECTOR3D
			current_angle: DOUBLE
			vertex_indices, normal_indices, uvw_indices: ARRAYED_LIST[INTEGER]
			current_face: TE_3D_FACE
			single_cluster: TE_3D_CLUSTER
			i: INTEGER
		do
			create vertex_list.make(some_points.count*2)
			create normal_list.make(1)
			create face_list.make((some_points.count-1)*2)
			create uvw_sets.make(1)
			create current_uvw_set.make(0)

			create uvw_indices.make(0)
			--create cluster
			create cluster_list.make(1)
			create single_cluster.make(material)

			up_vector.set(0.0, 1.0, 0.0)
			--create normal
			normal_list.force(up_vector)
			-- create first two vertices
			current_point := some_points.i_th(1)
			next_point := some_points.i_th(2)
			current_bisector := up_vector.cross_product(next_point-current_point).normalized  * (a_width/2.0)
			vector := current_point + current_bisector
			vertex_list.force(vector)
			vector := current_point - current_bisector
			vertex_list.force(vector)
			from
				i := 2
			until
				i > some_points.count-1
			loop
				--create vertices
				last_point := some_points.i_th(i-1)
				current_point := some_points.i_th(i)
				next_point := some_points.i_th(i+1)
				current_angle := angle_between_vectors((last_point-current_point),(next_point-current_point))/2.0
				current_bisector := up_vector.cross_product(((next_point-current_point) + (current_point-last_point)).normalized)
				current_bisector := current_bisector * (a_width/(2.0*sine(current_angle)))
				vector := current_point + current_bisector
				vertex_list.force(vector)
				vector := current_point - current_bisector
				vertex_list.force(vector)

				--create first triangle of quad
				create new_uvw_index_set.make(1)
				create vertex_indices.make(3)
				create normal_indices.make(3)

				vertex_indices.force(i+(i-3))
				vertex_indices.force(i+(i-2))
				vertex_indices.force(i+(i-1))

				normal_indices.force(1)
				normal_indices.force(1)
				normal_indices.force(1)

				new_uvw_index_set.force(uvw_indices)
				create current_face.make(vertex_indices, normal_indices,new_uvw_index_set, vertex_list.i_th (vertex_indices.i_th (1)),vertex_list.i_th (vertex_indices.i_th (2)),vertex_list.i_th (vertex_indices.i_th (3)))
				face_list.force(current_face)
				single_cluster.push_index (face_list.count)


				--create second triangle of quad
				create new_uvw_index_set.make(1)
				create vertex_indices.make(3)
				create normal_indices.make(3)

				vertex_indices.force(i+(i-2))
				vertex_indices.force(i+(i))
				vertex_indices.force(i+(i-1))

				normal_indices.force(1)
				normal_indices.force(1)
				normal_indices.force(1)

				new_uvw_index_set.force(uvw_indices)

				create current_face.make(vertex_indices, normal_indices,new_uvw_index_set, vertex_list.i_th (vertex_indices.i_th (1)),vertex_list.i_th (vertex_indices.i_th (2)),vertex_list.i_th (vertex_indices.i_th (3)))
				face_list.force(current_face)
				single_cluster.push_index (face_list.count)

--				current_bisector := up_vector.cross_product(((next_point-current_point).normalized + (current_point-last_point).normalized).normalized)
				i := i+1
			end
			-- create last two vertices
			i := some_points.count
			current_point := some_points.i_th(i)
			last_point := some_points.i_th(i-1)
			current_bisector := up_vector.cross_product(current_point-last_point).normalized  * (a_width/2.0)
			vector := current_point + current_bisector
			vertex_list.force(vector)
			vector := current_point - current_bisector
			vertex_list.force(vector)

			--create first triangle of last quad
			create new_uvw_index_set.make(1)
			create vertex_indices.make(3)
			create normal_indices.make(3)

			vertex_indices.force(i+(i-3))
			vertex_indices.force(i+(i-2))
			vertex_indices.force(i+(i-1))

			normal_indices.force(1)
			normal_indices.force(1)
			normal_indices.force(1)

			new_uvw_index_set.force(uvw_indices)
			create current_face.make(vertex_indices, normal_indices,new_uvw_index_set, vertex_list.i_th (vertex_indices.i_th (1)),vertex_list.i_th (vertex_indices.i_th (2)),vertex_list.i_th (vertex_indices.i_th (3)))
			face_list.force(current_face)
			single_cluster.push_index (face_list.count)


			--create secound triangle of last quad
			create new_uvw_index_set.make(1)
			create vertex_indices.make(3)
			create normal_indices.make(3)

			vertex_indices.force(i+(i-2))
			vertex_indices.force(i+(i))
			vertex_indices.force(i+(i-1))

			normal_indices.force(1)
			normal_indices.force(1)
			normal_indices.force(1)

			new_uvw_index_set.force(uvw_indices)

			create current_face.make(vertex_indices, normal_indices,new_uvw_index_set, vertex_list.i_th (vertex_indices.i_th (1)),vertex_list.i_th (vertex_indices.i_th (2)),vertex_list.i_th (vertex_indices.i_th (3)))
			face_list.force(current_face)
			single_cluster.push_index (face_list.count)


			cluster_list.force(single_cluster)

			calculate_face_neighbours
			build_ressource_list
			last_3d_member := build_3d_member

		end

end
