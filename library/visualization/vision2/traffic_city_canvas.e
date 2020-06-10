note
	description: "City widget for vision2"
	date: "$Date$"
	revision: "$Revision$"

class
	TRAFFIC_CITY_CANVAS

inherit

	ZOOMABLE_CANVAS
		redefine
			make,
			redraw_now
		end

	TRAFFIC_CITY_WIDGET
		undefine
			copy,
			default_create,
			is_equal
		redefine
			set_city,
			enable_city_hidden,
			disable_city_hidden
		end

	KL_SHARED_FILE_SYSTEM
		undefine
			default_create,
			is_equal,
			copy
		end

create
	make

feature -- Initialization

	make
			-- Initialize canvas.
		local
			figure_world : EV_FIGURE_WORLD
			e: EV_ENVIRONMENT
		do
			create internal_factory
			create internal_station_representations.make
			create internal_line_representations.make
			create internal_road_representations.make
			create internal_building_representations.make
			create internal_moving_representations.make
			create internal_route_representations.make
			create background_polygons.make
			default_create
			create visible_area.make (
				create {REAL_COORDINATE}.make(0.0,0.0),
				create {REAL_COORDINATE}.make(1.0,1.0)
			)
			add_taxi_agent := agent add_taxi (?)
			remove_taxi_agent := agent remove_taxi (?)
			create figure_world
			create object_list.make
			create projector.make (figure_world,Current)
			set_zoom_limits (0.5, 2)
			zoom_factor := 1.0
			has_pending_redraw := false
			redraw_agent := agent redraw_now
			mouse_wheel_actions.extend (agent zoom)
			pan_agent := agent pan
			pointer_button_release_actions.extend (agent move_end)
			pointer_button_press_actions.extend (agent move_start)
			pointer_leave_actions.extend (agent release)

			create e
			e.application.add_idle_action (agent fast_redraw_now)

			zoom_out (zoom_maximum)
		end

feature -- Element change

	set_city (a_city: TRAFFIC_CITY)
			-- Set city that is displayed to `a_city'.
		do
			create internal_station_representations.make
			create internal_line_representations.make
			create internal_road_representations.make
			create internal_building_representations.make
			create internal_moving_representations.make
			create internal_route_representations.make
			create background_polygons.make
			add_background_polygons (a_city.background_polygons)
			object_list.wipe_out
			Precursor (a_city)
			redraw
		end

feature -- Status setting

	enable_city_hidden
			-- Set `is_city_hidden' to `True'.
		do
			is_city_hidden := True
			redraw
		end

	disable_city_hidden
			-- Set `is_city_hidden' to `False'.
		do
			is_city_hidden := False
			redraw
		end

feature -- Access

	line_representations:  TRAFFIC_VIEW_CONTAINER [TRAFFIC_LINE, TRAFFIC_VIEW [TRAFFIC_LINE]]
			-- Container for line views
		do
			Result := internal_line_representations
		end

	road_representations:  TRAFFIC_VIEW_CONTAINER [TRAFFIC_ROAD, TRAFFIC_VIEW [TRAFFIC_ROAD]]
			-- Container for road views
		do
			Result := internal_road_representations
		end

	route_representations:  TRAFFIC_VIEW_CONTAINER [TRAFFIC_ROUTE, TRAFFIC_VIEW [TRAFFIC_ROUTE]]
			-- Container for route views
		do
			Result := internal_route_representations
		end

	station_representations: TRAFFIC_VIEW_CONTAINER [TRAFFIC_STATION, TRAFFIC_VIEW [TRAFFIC_STATION]]
			-- Container for station views
		do
			Result := internal_station_representations
		end

	building_representations: TRAFFIC_VIEW_CONTAINER [TRAFFIC_BUILDING, TRAFFIC_VIEW [TRAFFIC_BUILDING]]
			-- Container for building views
		do
			Result := internal_building_representations
		end

	moving_representations: TRAFFIC_VIEW_CONTAINER [TRAFFIC_MOVING, TRAFFIC_VIEW [TRAFFIC_MOVING]]
			-- Container for moving views
		do
			Result := internal_moving_representations
		end

	factory: TRAFFIC_VIEW_FACTORY
			-- Factory for creating views
		do
			Result := internal_factory
		end

feature -- Basic operations

	redraw_now
			-- Refresh all items on `Current'.
		do
			background_color.set_rgb (1.0, 1.0, 1.0)
			clear
			if not is_city_hidden and city /= Void then
				clear
				from
					background_polygons.start
				until
					background_polygons.after
				loop
					background_polygons.item.draw (Current)
					background_polygons.forth
				end
				internal_road_representations.draw (Current)
				internal_line_representations.draw (Current)
				internal_station_representations.draw (Current)
				internal_building_representations.draw (Current)
				create map_image.make_with_size (width, height)
				map_image.draw_pixmap (0, 0, Current)
				fast_redraw_now
				has_pending_redraw := false
				(create {EV_ENVIRONMENT}).application.remove_idle_action (redraw_agent)
			end
		end

	fast_redraw_now
			-- Refresh only the objects in mutable_object_list.
		do
			clear
			if not is_city_hidden then
				if map_image /= Void then
					draw_pixmap (0, 0, map_image)
				end
				internal_route_representations.draw (Current)
				internal_moving_representations.draw (Current)
			end
			from
				object_list.start
			until
				object_list.after
			loop
				object_list.item_for_iteration.draw (Current)
				object_list.forth
			end
		end


feature {NONE} -- Implementation

	internal_factory: TRAFFIC_VS_VIEW_FACTORY
	internal_moving_representations: TRAFFIC_VS_VIEW_CONTAINER [TRAFFIC_MOVING]
	internal_route_representations: TRAFFIC_VS_VIEW_CONTAINER [TRAFFIC_ROUTE]
	internal_line_representations: TRAFFIC_VS_VIEW_CONTAINER [TRAFFIC_LINE]
	internal_road_representations: TRAFFIC_VS_VIEW_CONTAINER [TRAFFIC_ROAD]
	internal_station_representations: TRAFFIC_VS_VIEW_CONTAINER [TRAFFIC_STATION]
	internal_building_representations: TRAFFIC_VS_VIEW_CONTAINER [TRAFFIC_BUILDING]
	map_image: EV_PIXMAP
	background_polygons: LINKED_LIST[DRAWABLE_POLYGON]

	add_background_polygons(polygons: LINKED_LIST[TRAFFIC_POLYGON])
		-- adds `polygons' to `background_polygons'  (converted to DRAWABLE_POLYGON)
	local
		c: EV_COLOR
		ct: TRAFFIC_COLOR
		p: DRAWABLE_POLYGON
	do
		from
			polygons.start
		until
			polygons.after
		loop
			create p.make (polygons.item.points_with_y_inverted)
			ct := polygons.item.color
			create c.make_with_8_bit_rgb (ct.red, ct.green, ct.blue)
			p.set_color (c)
			background_polygons.extend(p)
			polygons.forth
		end

	end

end
