note
	description: "Part of a TRAFFIC_ROUTE,%
		% goes from `origin' to `destination' using a SINGLE line or walking"
	date: "$Date$"
	revision: "$Revision$"

class
	TRAFFIC_LEG

inherit

	ANY
		redefine
			default_create
		end

create
	default_create, make, make_tram, make_bus, make_rail, make_walk_with_road, make_metro, make_walk

feature {NONE} -- Creation

	default_create
			-- Initialize `Current'.
		do
			create segments.make
		end

	make (a_segment: TRAFFIC_SEGMENT)
			-- Initialize `current', used if line-type  unknown.
		require
			a_segment_exists: a_segment /= Void
		local
			ls: TRAFFIC_LINE_SEGMENT
		do
			ls ?= a_segment
			if ls /= Void then
				line := ls.line
			end
			length := a_segment.length
			if segments = Void then
				default_create
			end
			extend (a_segment)
		end

	make_tram (a_line_segment: TRAFFIC_LINE_SEGMENT)
			-- Initialize `Current' of type tram.
		require
			line_segment_exists: a_line_segment /= Void
			line_segment_is_tram: is_tram (a_line_segment)
		do
			line := a_line_segment.line
			length := a_line_segment.length
			if segments = Void then
				default_create
			end
			extend (a_line_segment)
		end

	make_metro (a_origin, a_destination: TRAFFIC_STATION)
			-- Make `Current' from `a_origin' to `a_destination' of type tram.
		require
			at_least_one_common_line: not a_origin.lines.disjoint (a_destination.lines)
		local
			lines: LINKED_SET[TRAFFIC_LINE]
			seg: LINKED_LIST[TRAFFIC_LINE_SEGMENT]
		do
			lines := a_origin.lines.twin
			lines.intersect (a_destination.lines)
			line := lines.first -- take an arbritary line
			if segments = Void then
				default_create
			end

			seg := line.get_segments (a_origin, a_destination)
			from
				seg.start
			until
				seg.after
			loop
				extend(seg.item)
				seg.forth
			end

		end

	make_bus (a_line_segment: TRAFFIC_LINE_SEGMENT)
			-- Initialize `Current' of type bus.
		require
			line_sectin_exists: a_line_segment /= Void
			line_segment_is_bus: is_bus (a_line_segment)
		do
			line := a_line_segment.line
			length := a_line_segment.length
			if segments = Void then
				default_create
			end
			extend (a_line_segment)
		end

	make_rail (a_line_segment: TRAFFIC_LINE_SEGMENT)
			-- Initialize `Current' ob type rail.
		require
			line_segment_exists: a_line_segment /= Void
			line_segment_is_rail: is_rail (a_line_segment)
		do
			line := a_line_segment.line
			length := a_line_segment.length
			if segments = Void then
				default_create
			end
			extend (a_line_segment)
		end

	make_walk_with_road (a_road: TRAFFIC_ROAD_SEGMENT)
			-- Initialize `Current' of type walk.
		require
			road_exists: a_road /= Void
			road_is_for_walking: a_road.type.is_allowed_walking
		do
			length := a_road.length
			if segments = Void then
				default_create
			end
			extend (a_road)
		end

	make_walk (a_origin, a_destination: TRAFFIC_STATION)
			-- Initialize `Current' of type walk.
		require
			directly_connected_by_one_road: a_origin.is_road_connected (a_destination)
		local
			segment: TRAFFIC_ROAD_SEGMENT
			road: TRAFFIC_ROAD
		do
			road := a_origin.connecting_road (a_destination)
			segment := road.get_connecting_segment (a_origin, a_destination)
			if segments = Void then
				default_create
			end
			extend (segment)
		end



feature -- Access

	type: TRAFFIC_TYPE
			-- Type of the route segment
		do
			Result := segments.first.type
		end

	origin: TRAFFIC_STATION
			-- Origin of the route
		do
			Result := segments.first.origin
		end

	destination: TRAFFIC_STATION
			-- Destination of the route
		do
			Result := segments.last.destination
		end

	line: TRAFFIC_LINE
			-- Line used

	length: REAL_64
			-- Length of segment

	segments: TRAFFIC_EVENT_LINKED_LIST [TRAFFIC_SEGMENT]
			-- Segments that are used by the route segment

	next: TRAFFIC_LEG
			-- Next route segment

feature -- Status report

	has_line: BOOLEAN
			-- Does this route segment use a line?
		do
			Result := line /= Void
		end

	is_insertable (a_segment: TRAFFIC_SEGMENT): BOOLEAN
			-- Can `a_segment' be inserted?
		require
			a_segment_exists: a_segment /= Void
		local
			l: TRAFFIC_LINE_SEGMENT
		do
			Result := True
			if not segments.is_empty then
				if has_line then
					l ?= a_segment
					if l /= Void then
						Result := (l.line = line)
					else
						Result := False
					end
				end
				Result := Result and (a_segment.origin = segments.last.destination) and a_segment.type.is_equal (segments.last.type)
			end
		end

	is_joinable (a_segment: TRAFFIC_LEG): BOOLEAN
			-- Can `a_segment' be inserted?
		require
			a_segment_exists: a_segment /= Void
		do
			Result := a_segment.segments = Void or else is_insertable (a_segment.segments.first)
		end

	is_valid_next (a_segment: TRAFFIC_LEG): BOOLEAN
			-- Is the origin of `a_segment' the same station as the current destination?
		require
			a_segment_exists: a_segment /= Void
		do
			Result := segments = Void or else destination = a_segment.origin

		end

	is_tram (a_line_segment: TRAFFIC_LINE_SEGMENT): BOOLEAN
			-- is `a_line_segment' of type tram?
		require
			a_line_segment_exists: a_line_segment /= Void
		local
			tram_type: STRING
		do
			tram_type := (create {TRAFFIC_TYPE_TRAM}.make).name
			-- is ls.line realy of type traffic_type_tram
			Result := a_line_segment.line.type.name.is_equal (tram_type)
		end

	is_bus (a_line_segment: TRAFFIC_LINE_SEGMENT): BOOLEAN
			-- is `a_line_segment' of type tram?
		require
			a_line_segment_exists: a_line_segment /= Void
		local
			bus_type: STRING
		do
			bus_type := (create {TRAFFIC_TYPE_BUS}.make).name
			-- is ls.line realy of type traffic_type_bus
			Result := a_line_segment.line.type.name.is_equal (bus_type)
		end

	is_rail (a_line_segment: TRAFFIC_LINE_SEGMENT): BOOLEAN
			-- is `a_line_segment' of type tram?
		require
			a_line_segment_exists: a_line_segment /= Void
		local
			train_type: STRING
		do
			train_type := (create {TRAFFIC_TYPE_RAIL}.make).name
			-- is ls.line realy of type traffic_type_train
			Result := a_line_segment.line.type.name.is_equal (train_type)
		end

feature -- Basic operations

	join (a_leg: TRAFFIC_LEG)
			-- Extend with `a_leg'.
		require
			leg_exists: a_leg /= Void
			leg_is_intertable: is_joinable (a_leg)
		do
			if not has_line then
				line := a_leg.line
			end
			length := length + a_leg.length
			from
				a_leg.segments.start
			until
				a_leg.segments.after
			loop
				segments.force_last (a_leg.segments.item_for_iteration)
				a_leg.segments.forth
			end
		end

	extend (a_segment: TRAFFIC_SEGMENT)
			-- Add `a_segment' to the end of the route leg.
		require
			a_segment_exists: a_segment /= Void
			a_segment_fits: is_insertable (a_segment)
		local
			l: TRAFFIC_LINE_SEGMENT
		do
			l ?= a_segment
			if (l /= Void and segments.is_empty) and then l.line /= Void then
				line := l.line
			end
			segments.force_last (a_segment)
			length := length + a_segment.length
		ensure
			one_more: segments.count = old segments.count + 1
		end

	set_next (a_leg: TRAFFIC_LEG)
			-- Set pointer to next route leg `a_leg'.
		require
			a_leg_exists: a_leg /= Void
			is_realy_next: is_valid_next (a_leg)
			is_different_type_of_line: not is_joinable (a_leg)
		do
			next := a_leg
		ensure
			next_set: next = a_leg
		end

end
