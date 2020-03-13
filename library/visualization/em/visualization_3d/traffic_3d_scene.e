indexing
	description: "Default scene with a map widget and buttons for opening an xml, zooming in and out"
	date: "$Date$"
	revision: "$Revision$"

class
	TRAFFIC_3D_SCENE

inherit

	TRAFFIC_EM_SCENE
		redefine
			map_widget
		end


creation
	make

feature {NONE} -- Initialization

	build_map_widget is
			--
		do
			if video_subsystem.opengl_enabled then
				create map_widget.make_with_size (width, height - 30)
				map_widget.set_position (0, 30)
				map_widget.mouse_dragged_event.subscribe (agent rotate_zoom_pan (?))
				map_widget.mouse_wheel_up_event.subscribe (agent map_widget.zoom_in)
				map_widget.mouse_wheel_down_event.subscribe (agent map_widget.zoom_out)
				map_widget.mouse_clicked_event.subscribe (agent click(?))
				add_component (map_widget)
			else
				io.put_string ("OpenGL disabled: Map not loaded%N")
			end
		end

	set_agents is
			-- Set the agents for the zoom in and zoom out buttons.
		do
			zoom_out_button.clicked_event.subscribe (agent zoom_out_button_clicked)
			zoom_in_button.clicked_event.subscribe (agent zoom_in_button_clicked)
		end

feature -- Event handling

	click (an_event: EM_MOUSEBUTTON_EVENT) is
			--
		do
			if an_event.is_right_button then
				--don't know yet
			elseif an_event.is_middle_button then
				--don't know yet
			elseif an_event.is_left_button then
				map_widget.pick_selection(an_event.screen_x, an_event.screen_y)
			end
		end

	rotate_zoom_pan (an_event: EM_MOUSEMOTION_EVENT) is
			-- Rotate camera around
		do
			if an_event.button_state_right then
				map_widget.rotate_camera (an_event.x_motion, an_event.y_motion)
			elseif an_event.button_state_middle then
				map_widget.zoom(an_event.y_motion)
			elseif an_event.button_state_left then
				map_widget.pan (an_event.x_motion, an_event.y_motion)
			end

		end

	zoom_in_button_clicked is
			-- "Zoom in" button has been clicked.
		require
			zoom_in_button /= Void
		do
			zoom_in_button.set_pressed (False)
			map_widget.zoom_in
		end

	zoom_out_button_clicked is
			-- "Zoom out" button has been clicked.
		require
			zoom_out_button /= Void
		do
			zoom_out_button.set_pressed (False)
			map_widget.zoom_out
		end

feature -- Access

	map_widget: TRAFFIC_3D_MAP_WIDGET

end
