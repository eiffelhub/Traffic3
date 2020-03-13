indexing
	description: "Objects that ..."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	TRAFFIC_EM_SCENE

inherit

	EM_COMPONENT_SCENE
		rename
			time as em_time
		redefine
			redraw
		end

	TRAFFIC_CONSTANTS
		export {NONE} all end

	EXCEPTIONS
		export {NONE} all end

	TRAFFIC_SHARED_TIME

	TE_3D_SHARED_GLOBALS

	EM_SHARED_BITMAP_FACTORY

feature {NONE} -- Initialization

	make is
			-- Create all checkboxes and gui elements.
		do
			make_component_scene

			set_frame_counter_visibility (False)

			build_map_widget

			build_quicktoolbar

			-- Time counter
			create time_counter.make
			time_counter.set_x_y (10, 40)
		end

	build_quicktoolbar is
			-- Build the quick toolbar panel with default buttons.
		local
			s: STRING
			fs: KL_FILE_SYSTEM
		do
			fs := (create {KL_SHARED_FILE_SYSTEM}).file_system
			-- Quick tools
			create quicktoolbar_panel.make_from_dimension (width, 30)
			quicktoolbar_panel.set_position (0, 0)
			add_component (quicktoolbar_panel)

			-- Open file
			s := fs.pathname ("..\image", "open.png")
			bitmap_factory.create_bitmap_from_image (s)
			create open_button.make_from_image (bitmap_factory.last_bitmap)
			open_button.set_optimal_dimension (26, 25)
			open_button.resize_to_optimal_dimension
			open_button.set_position (2, 2)
			open_button.clicked_event.subscribe (agent choose_file)
			quicktoolbar_panel.add_widget (open_button)

			-- Zoom out Button
			s := fs.pathname ("..\image", "zoom_out.png")
			bitmap_factory.create_bitmap_from_image (s)
			create zoom_out_button.make_from_image (bitmap_factory.last_bitmap)
			zoom_out_button.set_optimal_dimension (26, 25)
			zoom_out_button.resize_to_optimal_dimension
			zoom_out_button.set_position (58, 2)
			quicktoolbar_panel.add_widget (zoom_out_button)

			-- Zoom in Button
			s := fs.pathname ("..\image", "zoom_in.png")
			bitmap_factory.create_bitmap_from_image (s)
			create zoom_in_button.make_from_image (bitmap_factory.last_bitmap)
			zoom_in_button.set_optimal_dimension (26, 25)
			zoom_in_button.resize_to_optimal_dimension
			zoom_in_button.set_position (86, 2)
			quicktoolbar_panel.add_widget (zoom_in_button)
		end

	build_map_widget is
			-- Set up the map widget (either 2d or 3d).
		deferred
		ensure
			map_widget_exists: map_widget /= Void
		end

	set_agents is
			-- Set the agents for the zoom in and zoom out buttons.
		deferred
		end

feature -- Basic operations

	redraw is
			--
		local
			cursor: DS_BILINKED_LIST_CURSOR [EM_COMPONENT]
			component: EM_COMPONENT
		do

			if video_subsystem.opengl_enabled then
				gl_color3f_external(1.0, 1.0, 1.0)
				emgl_clear (Em_gl_color_buffer_bit | Em_gl_depth_buffer_bit)
			end
			from
				cursor := components_impl.new_cursor
				cursor.start
			until
				cursor.off
			loop
				component := cursor.item
				if component.is_visible then
					component.redraw
				end
				cursor.forth
			end
			if is_frame_counter_displayed then
				if video_subsystem.opengl_enabled and not video_subsystem.video_surface.is_opengl_blitting_enabled then
					video_subsystem.video_surface.enable_opengl_blitting
				end
				frame_counter.draw (screen)
			end
			if video_subsystem.opengl_enabled and not video_subsystem.video_surface.is_opengl_blitting_enabled then
				video_subsystem.video_surface.enable_opengl_blitting
			end
			time_counter.draw (screen)

			screen.redraw
		end

feature -- Event handling

	choose_file is
			-- Open file dialog and choose a map to load.
		local
			dlg: TRAFFIC_FILE_DIALOG
		do
			create dlg.make
			dlg.add_file_filter ("Traffic xml files (*.xml)", "xml")
			dlg.show
			dlg.button_clicked_event.subscribe (agent open_file (dlg))
		end

	open_file (a_dlg: EM_FILE_DIALOG) is
			-- File dialog was closed, now load a map.
		local
			loader: TRAFFIC_MAP_LOADER
			dlg: EM_MESSAGE_DIALOG
		do
			if a_dlg.was_ok_clicked and a_dlg.is_file_selected then
				create loader.make (a_dlg.absolute_filename)
				loader.enable_dump_loading
				loader.load_map
				if not loader.has_error then
					map_widget.set_map (loader.map)
					loaded_file_name := a_dlg.filename
				else
					create dlg.make_from_error ("Error parsing" + a_dlg.filename)
					io.put_string ("bad error!!")
					dlg.show
				end

			end
		end

feature -- Access

	quicktoolbar_panel: EM_PANEL
			-- Panel on the top where quick tools are located

	open_button: EM_BUTTON
			-- Button for opening xml files

	zoom_in_button: EM_BUTTON
			-- Botton to zoom in

	zoom_out_button: EM_BUTTON
			-- Botton to zoom out

	fps_label: EM_FPS_LABEL
			-- Frame counter label

	time_counter: TRAFFIC_TIME_COUNTER
			-- Time counter label

	map_widget: TRAFFIC_MAP_WIDGET
			-- The 3 dimensional representation of the map

feature {NONE} -- Implementation

	loaded_file_name: STRING
			-- Name of the currently loaded

end
