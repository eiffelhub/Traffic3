indexing
	description: "Objects that ..."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	TRAFFIC_2D_SCENE

inherit

	TRAFFIC_EM_SCENE
		redefine
			map_widget
		end

feature -- Initialization

	build_map_widget is
			-- Set up map widget.
		do
			create drawing_panel.make_from_dimension (width, height - 30)
			create map_widget.make_with_size (width, height - 30)
			drawing_panel.set_position (0, 30)
--			map_widget.mouse_wheel_up_event.subscribe (agent map_widget.zoom_in)
--			map_widget.mouse_wheel_down_event.subscribe (agent map_widget.zoom_out)
			drawing_panel.container.force_last (map_widget)
			drawing_panel.set_background_color (create {EM_COLOR}.make_white)
			add_component (drawing_panel)
		end

	set_agents is
			--
		do

		end

feature -- Access

	map_widget: TRAFFIC_2D_MAP_WIDGET

	drawing_panel: EM_DRAWABLE_PANEL

end
