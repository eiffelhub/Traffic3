indexing
	description: "Objects that ..."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	TRAFFIC_3D_VIEW_FACTORY

inherit

	TRAFFIC_VIEW_FACTORY
		redefine
			default_create
		end

feature -- Initialization

	default_create is
			--
		do
			create building_view_factory
			create line_connection_view_factory.make
			create road_connection_view_factory.make
			road_connection_view_factory.set_width (10)
			create moving_view_factory
			create place_view_factory.make
		end


feature -- Factory methods

	new_place_view (a_place: TRAFFIC_PLACE): TRAFFIC_VIEW [TRAFFIC_PLACE] is
			-- New place view for `a_place'
		do
			Result := place_view_factory.new_place_member (a_place)
			Result.set_color (create {TRAFFIC_COLOR}.make_black)
		end

	new_path_view (a_path: TRAFFIC_PATH): TRAFFIC_VIEW [TRAFFIC_PATH] is
			-- New path view for `a_path'
		local
			conns: DS_LIST [TRAFFIC_CONNECTION]
			p_v: TRAFFIC_3D_RENDERABLE [TRAFFIC_PATH]
			c: TRAFFIC_3D_RENDERABLE [TRAFFIC_CONNECTION]
			pl: TRAFFIC_3D_RENDERABLE [TRAFFIC_PLACE]
		do
			create p_v.make (a_path)
			from
				conns := a_path.connections
				conns.start
			until
				conns.after
			loop
				c := line_connection_view_factory.new_connection (conns.item_for_iteration)
				c.set_color (create {TRAFFIC_COLOR}.make_with_rgb (255, 0, 0))
				c.set_as_child_of (p_v)
				pl := place_view_factory.new_place_member (conns.item_for_iteration.origin)
				pl.set_color (create {TRAFFIC_COLOR}.make_with_rgb (255, 0, 0))
				pl.set_as_child_of (p_v)
				pl := place_view_factory.new_place_member (conns.item_for_iteration.destination)
				pl.set_color (create {TRAFFIC_COLOR}.make_with_rgb (255, 0, 0))
				pl.set_as_child_of (p_v)
				conns.forth
			end
			Result := p_v
		end

	new_line_view (a_line: TRAFFIC_LINE): TRAFFIC_VIEW [TRAFFIC_LINE] is
			-- New line view for `a_line'
		local
			l_v: TRAFFIC_3D_RENDERABLE [TRAFFIC_LINE]
			l: TRAFFIC_3D_RENDERABLE [TRAFFIC_CONNECTION]
			lc: TRAFFIC_LINE_CURSOR
		do
			create l_v.make (a_line)
			from
				create lc.make (a_line)
				lc.start
			until
				lc.after
			loop
				l := line_connection_view_factory.new_connection (lc.item_for_iteration)
				l.set_color (a_line.color)
				l_v.add_child (l)
				lc.forth
			end
			Result := l_v
			l_v.set_color (a_line.color)
		end

	new_road_view (a_road: TRAFFIC_ROAD): TRAFFIC_VIEW [TRAFFIC_ROAD] is
			-- New road view for `a_road'
		local
			r: TRAFFIC_3D_RENDERABLE [TRAFFIC_ROAD]
			s: TRAFFIC_3D_RENDERABLE [TRAFFIC_CONNECTION]
		do
			create r.make (a_road)
			s := road_connection_view_factory.new_connection (a_road.one_way)
			s.set_color (create {TRAFFIC_COLOR}.make_with_rgb (125, 125, 125))
			r.add_child (s)
			Result := r
		end

	new_building_view (a_building: TRAFFIC_BUILDING): TRAFFIC_VIEW [TRAFFIC_BUILDING] is
			-- New building view for `a_building'
		do
			if a_building.is_villa then
				Result := building_view_factory.new_villa_member (a_building)
			elseif a_building.is_skyscraper then
				Result := building_view_factory.new_skyscraper_member (a_building)
			else
				Result := building_view_factory.new_apartment_building_member (a_building)
			end
		end

	new_tram_view (a_tram: TRAFFIC_TRAM): TRAFFIC_VIEW [TRAFFIC_TRAM] is
			-- New tram view for `a_tram'
		do
			Result := moving_view_factory.new_tram_daynight_member (a_tram)
		end

	new_bus_view (a_bus: TRAFFIC_BUS): TRAFFIC_VIEW [TRAFFIC_BUS] is
			-- New bus view for `a_bus'
		do
			Result := moving_view_factory.new_bus_daynight_member (a_bus)
		end

	new_taxi_view (a_taxi: TRAFFIC_TAXI): TRAFFIC_VIEW [TRAFFIC_TAXI] is
			-- New taxi view for `a_taxi'
		do
			Result := moving_view_factory.new_taxi_daynight_member (a_taxi)
			Result.set_color (a_taxi.office.color)
		end

	new_passenger_view (a_passenger: TRAFFIC_PASSENGER): TRAFFIC_VIEW [TRAFFIC_PASSENGER] is
			-- New passenger view for `a_passenger'
		do
			Result := moving_view_factory.new_person_member (a_passenger)
		end

	new_free_moving_view (a_free_moving: TRAFFIC_FREE_MOVING): TRAFFIC_VIEW [TRAFFIC_FREE_MOVING] is
			-- New free_moving view for `free_moving'
		do
			Result := moving_view_factory.new_free_moving_member (a_free_moving)
			Result.set_color (create {TRAFFIC_COLOR}.make_with_rgb (120, 255, 255))
		end

feature -- External factories

	building_view_factory: TRAFFIC_3D_BUILDING_FACTORY

	line_connection_view_factory: TRAFFIC_3D_CONNECTION_FACTORY

	road_connection_view_factory: TRAFFIC_3D_CONNECTION_FACTORY

	moving_view_factory: TRAFFIC_3D_MOVING_FACTORY

	place_view_factory: TRAFFIC_3D_PLACE_FACTORY

end
