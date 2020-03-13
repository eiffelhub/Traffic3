indexing
	description: "Camera_object"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	TE_3D_CAMERA inherit

		TE_3D_NODE
			redefine
				make_as_child, make
			end

		DOUBLE_MATH

		MATH_CONST

		GL_FUNCTIONS

		GLU_FUNCTIONS

		EM_GL_CONSTANTS

	create
		make_as_child, make

feature {NONE} -- Initialize

	make_as_child (a_parent: TE_3D_NODE) is
			--create camera as child of 'a_parent'
		do
			Precursor(a_parent)
			create target.make_from_tuple ([0.0, 0.0, 0.0])
			create view_frustum.make
			look_at_target

			gl_matrix_mode(em_GL_MODELVIEW)
			gl_push_Matrix
			gl_matrix_mode(em_GL_PROJECTION)
			gl_push_Matrix
			specify
			gl_get_doublev(em_GL_PROJECTION_MATRIX, projection_matrix.to_pointer)
			gl_pop_Matrix
			gl_matrix_mode(EM_GL_MODELVIEW)
			gl_pop_Matrix
		end

	make is
			-- creates camera without a parent. Insert the camera into the hierarchy if you want to use it
		do
			Precursor
			create target.make_from_tuple ([0.0, 0.0, 0.0])
			create view_frustum.make
			frustum_culling_enabled := true
			transform.set_position (300.0,300.0,300.0)
			transform.event_channel.subscribe(agent look_at_target)

			gl_matrix_mode(em_GL_MODELVIEW)
			gl_push_Matrix
			gl_matrix_mode(em_GL_PROJECTION)
			gl_push_Matrix
			specify
			gl_get_doublev(em_GL_PROJECTION_MATRIX, projection_matrix.to_pointer)
			gl_pop_Matrix
			gl_matrix_mode(EM_GL_MODELVIEW)
			gl_pop_Matrix
		end

feature -- Access

	view_frustum: LINKED_LIST[EM_PLANE]
		-- near, far, left, right, bottom and top plane of the view_frustum in WORLDSPACE COORDINATES!

	fov: DOUBLE is 45.0
		-- view angle in y direction

	aspect: DOUBLE is 1.0 -- 1:1
			-- aspect ratio that determines the field of view in the x direction. The aspect ratio is the ratio of x (width) to y (height).

	near: DOUBLE is 28.5--250.0--1.05
		-- distance from the viewer to the near clipping plane (always positive).

	far: DOUBLE is 120000.0-- 500.0
		-- distance from the viewer to the far clipping plane (always positive).

	direction: EM_VECTOR3D is
		-- direction, the camera is pointing at
		local
		do
			result := -world_transform.z_axis
		end

	target: EM_VECTOR3D --worldspace target

	projection_matrix: EM_MATRIX44
		-- projection matrix dependant from fov

	frustum_culling_enabled: BOOLEAN
	-- frustum culling state. Activated frustum culling of 3D members takes only effect if the frustum culling of the camera is activated!!
	-- if frustum culling is not used, this state should be disabled!

feature -- Measurement


feature -- Status report

feature -- Status setting

	enable_frustum_culling is
			-- enables frustum culling for all 3d members, which have frustum_culling enabled
		do
			frustum_culling_enabled := true
		end

	disable_frustum_culling is
			-- disables frustum culling for all 3d members
		do
			frustum_culling_enabled := false
		end

feature -- Cursor movement

feature -- Element change

	set_target (a_target: EM_VECTOR3D) is
			-- Set `target' to `a_target'.
		require
			a_target_not_void: a_target /= Void
		do
			target := a_target
			look_at_target
		ensure
			target_set: target = a_target
		end



feature -- Removal

feature -- Resizing

feature -- Transformation

feature -- Conversion

feature -- Duplication

feature -- Miscellaneous

feature -- Basic operations

	specify is
			-- specifies the current camera settings. MUST BE CALLED WHEN THE MODELVIEW MATRIX IS IN ROOT SPACE! I.E. BEFORE THE HIERARCHY GETS DRAWN!
		local
			pos,tar,up: EM_VECTOR3D
			wt: TE_3D_TRANSFORM
		do
			gl_push_attrib(em_GL_TRANSFORM_BIT)
			gl_matrix_mode (em_GL_PROJECTION)
			gl_load_identity

			--gl_frustum(-1.0,1.0,-1.0,1.0,near,far)
			glu_perspective (fov, aspect, near, far)

			wt := world_transform
			pos := wt.position
			--tar := pos - wt.z_axis

			up.set(0.0,1.0,0.0)
			glu_look_at(pos.x,pos.y,pos.z, target.x,target.y,target.z, up.x,up.y,up.z)
			gl_pop_attrib
		end


feature -- Obsolete

feature -- Inapplicable

feature -- Implementation

	update_view_frustum is
			-- updates the view frustum
		local
			aux,normal,x,y,z, p, fc, nc: EM_VECTOR3D
			nh, nw, fh, fw, tang, ang2rad : DOUBLE
			nearp, farp, leftp, rightp, bottomp, topp: EM_PLANE
			wt : TE_3D_TRANSFORM
		do
			-- compute width and height of the near and far plane sections
			ang2rad := 3.14159265358979323846/180.0
			tang := tangent(ang2rad * fov * 0.5)
			nh := near * tang
			nw := nh * aspect
			fh := far  * tang
			fw := fh * aspect

			wt := world_transform
			x := wt.x_axis
			y := wt.y_axis
			p := wt.position

			nc := p - z * near;
			fc := p - z * far;

			--nearplane
			nearp.set_from_normal(nc, -z)
			view_frustum.extend(nearp)

			--farplane
			farp.set_from_normal(fc, z)
			view_frustum.extend(farp)

			--leftplane
			aux := (nc - x*nw) - p
			aux.normalize
			normal := aux.cross_product(y)
			leftp.set_from_normal(nc-x*nw, normal)
			view_frustum.extend(leftp)

			--rightplane
			aux := (nc + x*nw) - p
			aux.normalize
			normal := y.cross_product(aux);
			rightp.set_from_normal(nc+x*nw, normal)
			view_frustum.extend(rightp)

			--bottomplane
			aux := (nc - y*nh) - p
			aux.normalize
			normal := x.cross_product(aux)
			bottomp.set_from_normal(nc-y*nh, normal)
			view_frustum.extend(bottomp)

			--topplane
			aux := (nc + y*nh) - p
			aux.normalize
			normal := aux.cross_product(x)
			topp.set_from_normal(nc+y*nh, normal)
			view_frustum.extend(topp)
		end


	point_is_within_frustum (a_point: EM_VECTOR3D): BOOLEAN is
			-- returns true if the point is within the view_frustum. POINT MUST BE IN WORLDSPACE!!
		local
			break:BOOLEAN
		do
			Result := true
			from
				view_frustum.start
			until
				view_frustum.after or break = true
			loop
				if view_frustum.item.is_point_below(a_point) then
					Result := false
					break := true
				end
				view_frustum.forth
			end
		end

	sphere_is_within_frustum (a_sphere: TUPLE[EM_VECTOR3D, DOUBLE]): BOOLEAN is
			-- returns true if the sphere is partially within the view_frustum. PIVOT MUST BE IN WORLDSPACE!!
		local
			break: BOOLEAN
			a_point: EM_VECTOR3D
			a_radius: DOUBLE
		do
			Result := true
			from
				view_frustum.start
			until
				view_frustum.after or break = true
			loop
				a_point ?= a_sphere.item(1)
				a_radius ?= a_sphere.item(2)
				if view_frustum.item.distance_to_point(a_point) + a_radius < 0 then
					Result := false
					break := true
				end
				view_frustum.forth
			end
		end


feature {NONE} -- Implementation

	look_at_target is
			-- looks with -Z to the target with y pointing thorwards the upvector
		local
			world_up_vector: EM_VECTOR3D
			front,Cameraup: EM_VECTOR3D
			right,up: EM_VECTOR3D
			LookAt: EM_MATRIX44
		do
			world_up_vector.set(0.0,1.0,0.0)
			CameraUp := parent.world_transform.position + world_up_vector
			CameraUp := parent.worldspace_to_localspace (CameraUp)
			front := (parent.worldspace_to_localspace (target)-transform.position).normalized

			--up := CameraUp - Front*CameraUp.dot_product(Front)
			right := front.cross_product(cameraUp).normalized
			up := right.cross_product(front).normalized

--			LookAt.set (right.x, right.y, right.z, transform.position.x,
--						up.x, up.y, up.z, transform.position.y,
--						-front.x, -front.y, -front.z, transform.position.z,
--						target.x, target.y, target.z, 1.0)--0.0,0.0,0.0,1.0)

			LookAt.set (right.x, up.x, -front.x, transform.position.x,
						right.y, up.y, -front.y, transform.position.y,
						right.z, up.z, -front.z, transform.position.z,
						0.0, 0.0, 0.0, 1.0)--0.0,0.0,0.0,1.0)

			transform.set_model_matrix (LookAt)
		end

invariant
	target_not_void: target /= Void

end
