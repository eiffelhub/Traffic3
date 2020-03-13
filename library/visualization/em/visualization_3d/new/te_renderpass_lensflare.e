indexing
	description: "Objects that ..."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	TE_RENDERPASS_LENSFLARE inherit

		TE_RENDERPASS redefine make end

		EM_GL_CONSTANTS export {NONE} all end

		GL_FUNCTIONS export {NONE} all end

		GLU_FUNCTIONS export {NONE} all end

		TE_3D_SHARED_GLOBALS export {NONE} all end

		EM_SHARED_SUBSYSTEMS export {NONE} all end

		EM_TIME_SINGLETON

	create make

feature -- Initialization

	make is
			-- creates the lensflare pass and loads the images
		do
			Precursor
			create camera.make_as_child(root)
			load_flare("..\flares\default_flare.flr")
			specify_quad
			flare_position.set(-0.5,-0.5)
		end


feature -- Access

	camera: TE_3D_CAMERA

	flares: LINKED_LIST[TUPLE[GL_TEXTURE,DOUBLE,DOUBLE,DOUBLE]] -- linked list of flares. flare: TUPLE[imageNr, position, scale, opacity]

	flare_position: EM_VECTOR2D

	quad_displaylist: INTEGER

	node_to_trace: TE_3D_NODE

	max_intensity: DOUBLE is 1.0

	visible: BOOLEAN

	fade_time: INTEGER is 300
		--milisecounds for fade

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

	set_camera (a_camera:TE_3D_CAMERA) is
			-- sets the camera of the current renderpass
		require
			is_in_hierarchy: camera.parent /= Void
		do
			camera := a_camera
		end

	trace_3d_node(a_node: TE_3D_NODE) is
			-- traces the 3D node
		do
			node_to_trace:=a_node
		end


feature -- Obsolete

feature {NONE} -- Implementation

	load_flare(a_filename: STRING) is
			-- loads a flr lensflare definition which will be used
		local
			flr_file: PLAIN_TEXT_FILE
			tokenizer: TE_3D_TEXT_SCANNER
			bitmap_factory: EM_BITMAP_FACTORY
			path_name: STRING
			first_definition_set:BOOLEAN
			texture_lookup: HASH_TABLE[GL_TEXTURE,STRING]

			textures: ARRAYED_LIST[GL_TEXTURE]
			used_texture: GL_TEXTURE
			count:INTEGER
			pos_min, pos_max: DOUBLE
			scale_min, scale_max:DOUBLE
			opacity_min, opacity_max: DOUBLE
		do
			create flares.make
			create textures.make(1)
			create texture_lookup.make(1)
			bitmap_factory := (create{EM_SHARED_BITMAP_FACTORY}).bitmap_factory

			from
				create flr_file.make_open_read (a_filename)
				create tokenizer.make_from_string_with_delimiters ("", " %T")
			until
				flr_file.after
			loop
				flr_file.read_line
				if not flr_file.last_string.is_empty then
					tokenizer.set_source_string (flr_file.last_string)
					tokenizer.read_token

					if  tokenizer.last_string.is_equal ("source") then
						tokenizer.read_token
						path_name := a_filename.substring(1, a_filename.last_index_of('\', a_filename.count))
						bitmap_factory.create_bitmap_from_image(path_name + tokenizer.last_string)
						textures.extend(bitmap_factory.last_bitmap.texture)
						texture_lookup.force(bitmap_factory.last_bitmap.texture, tokenizer.last_string.twin)
					elseif tokenizer.last_string.is_equal ("newflare") then
						if first_definition_set then
							build_and_push_flares(used_texture, count, pos_min, pos_max, scale_min, scale_max, opacity_min, opacity_max)
						end
						tokenizer.read_token
						used_texture := texture_lookup.item(tokenizer.last_string)
						if used_texture = Void then
							io.put_string("Lensflare ERROR! texture " + tokenizer.last_string + " not found in texture_lookup! %N")
						end
						first_definition_set := true
					elseif tokenizer.last_string.is_equal ("count") then
						tokenizer.read_token
						count := tokenizer.last_string.to_integer
					elseif tokenizer.last_string.is_equal ("pos") then
						tokenizer.read_token
						pos_min := tokenizer.last_string.to_double
						tokenizer.read_token
						pos_max := tokenizer.last_string.to_double
					elseif tokenizer.last_string.is_equal ("scale") then
						tokenizer.read_token
						scale_min := tokenizer.last_string.to_double
						tokenizer.read_token
						scale_max := tokenizer.last_string.to_double
					elseif tokenizer.last_string.is_equal ("opacity") then
						tokenizer.read_token
						opacity_min := tokenizer.last_string.to_double
						tokenizer.read_token
						opacity_max := tokenizer.last_string.to_double
					end
				elseif flr_file.last_string.is_empty and first_definition_set then
					build_and_push_flares(used_texture, count, pos_min, pos_max, scale_min, scale_max, opacity_min, opacity_max)
				end
			end
		end

	build_and_push_flares(used_texture:GL_TEXTURE ;count:INTEGER; pos_min,pos_max,scale_min,scale_max,opacity_min,opacity_max:DOUBLE) is
			-- creates flares and pushes it to the flare list
		require
			texture_not_void: used_texture /= Void
		local
			i:INTEGER
			random:RANDOM
			pos,scale,opacity:DOUBLE
		do
			create random.make
			random.set_seed (out.hash_code)

			from
				i:=1
			until
				i>count
			loop
				pos :=(random.double_item*(pos_max-pos_min))+pos_min --interval[pos_min,pos_max]
				random.forth
				scale :=(random.double_item*(scale_max-scale_min))+scale_min --interval[pos_min,pos_max]
				random.forth
				opacity :=(random.double_item*(opacity_max-opacity_min))+opacity_min --interval[pos_min,pos_max]
				random.forth
				flares.extend([used_texture,pos,scale,opacity])
				i := i+1
			end
		end


feature {TE_RENDERPASS_MANAGER} -- rendering

	render is
			-- renders the current pass
		local
			position: EM_VECTOR2D
			texture: GL_TEXTURE
			pos:DOUBLE
			scale:DOUBLE
			opacity: DOUBLE
		do
			update_flare_position
			update_flare_intensity
			if intensity > 0 then

				gl_Push_Attrib( em_GL_COLOR_BUFFER_BIT | em_GL_DEPTH_BUFFER_BIT | em_GL_ENABLE_BIT | em_GL_POLYGON_BIT | em_GL_TEXTURE_BIT | em_GL_LIGHTING_BIT | em_GL_CURRENT_BIT)

				--render settings
				gl_Disable( em_GL_LIGHTING )
				gl_enable (em_GL_CULL_FACE)
				gl_depth_mask(0)
				gl_disable (Em_gl_depth_test)
				gl_enable (em_gl_texture_2d)

				--blend settings
				gl_enable(em_GL_BLEND)
				gl_blend_func(em_GL_ONE,em_GL_SRC_ALPHA)

				--draw some flares polygon
				gl_matrix_mode(em_GL_PROJECTION)
				gl_Push_Matrix
				gl_Load_Identity

				gl_matrix_mode(em_GL_MODELVIEW)

				from
					flares.start
				until
					flares.after
				loop
					texture ?= flares.item.item(1)
					pos ?= flares.item.item(2)
					scale ?= flares.item.item(3)
					opacity ?= flares.item.item(4)
					position := flare_position * pos

					gl_Color4d(intensity*opacity,intensity*opacity,intensity*opacity,1.0)
					gl_load_identity
					gl_translated(position.x, position.y, 0.0)
					gl_scaled(scale,scale,scale)
					gl_bind_texture (em_gl_texture_2d, texture.id)
					gl_call_list(quad_displaylist)

					flares.forth
				end

				gl_Pop_Matrix
				gl_Pop_Attrib
				gl_pop_client_attrib
			end--if
		end

		specify_quad is
				-- specifies the polygon to draw
			do
				quad_displaylist := gl_gen_lists (1)
				gl_new_list (quad_displaylist, em_GL_COMPILE)
					gl_Begin( em_GL_QUADS )
						gl_tex_coord2d(0.0,0.0)
						gl_Vertex3d(-1.0,-1.0,0.0)
						gl_tex_coord2d(1.0,0.0)
						gl_Vertex3d( 1.0,-1.0,0.0)
						gl_tex_coord2d(1.0,1.0)
						gl_Vertex3d( 1.0,1.0,0.0)
						gl_tex_coord2d(0.0,1.0)
						gl_Vertex3d(-1.0,1.0,0.0)
					gl_End
				gl_end_list
			end

		update_flare_intensity is
				-- fades the intensity
			local
				ticks_passed:INTEGER
			do
				ticks_passed := time.ticks - last_ticks_count

				if not visible and intensity > 0 then
					intensity := intensity - ticks_passed*(max_intensity/fade_time)
					if intensity < 0 then
						intensity := 0
					end
				end

				if visible and intensity < max_intensity then
					intensity := intensity + ticks_passed*(max_intensity/fade_time)
					if intensity > max_intensity then
						intensity := max_intensity
					end
				end

				last_ticks_count := time.ticks
			end


		update_flare_position is
				-- updates the 2d position of the flare
			local
				position3d: EM_VECTOR3D
				pj: ARRAY[DOUBLE]
				mm: ARRAY[DOUBLE]
				viewport: GL_VECTOR_4D [INTEGER]

				projection_matrix, model_matrix:EM_MATRIX44
				position4d: EM_VECTOR4D
				depth:REAL
				x_pos,y_pos:INTEGER
			do
				create viewport.make_xyzt (0,0,0,0)
				create pj.make(0,15)
				create mm.make(0,15)
				camera.specify
				gl_get_doublev(em_GL_PROJECTION_MATRIX, projection_matrix.to_pointer)
				gl_get_doublev(em_GL_MODELVIEW_MATRIX, model_matrix.to_pointer)
				gl_get_integerv(em_GL_VIEWPORT, viewport.pointer)

				position3d := node_to_trace.world_transform.position
				position4d := model_matrix.mult(vector4d(position3d))

				position4d := projection_matrix.mult (position4d) -- now position4d is in clip coordinates!
				--position4d := camera.projection_matrix.mult(position4d)

				--check for clipping
				if position4d.x.abs > position4d.w.abs or position4d.y.abs > position4d.w.abs or position4d.z.abs > position4d.w.abs then
					visible := false
				else
					visible := true
				end

				--check for occlusion
				x_pos := (viewport.z*(position4d.x/position4d.w+1)/2.0).rounded
				y_pos := (viewport.t*(position4d.y/position4d.w+1)/2.0).rounded
				gl_read_pixels_external (x_pos, y_pos, 1, 1, Em_gl_depth_component, Em_gl_float, $depth)
				if depth < position4d.z/position4d.w then
					visible := false
				end

				flare_position.set(position4d.x/position4d.w, position4d.y/position4d.w) --devide by w to get device coordinates
			end

--DEBUG
	vector4d(vector3d:EM_VECTOR3D): EM_VECTOR4D is
			--
		do
			Result.set(vector3d.x,vector3d.y,vector3d.z,1.0)
		end

--/DEBUG

	intensity:DOUBLE

	last_ticks_count:INTEGER

invariant
	invariant_clause: True -- Your invariant here

end
