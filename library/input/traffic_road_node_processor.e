note
	description: "XML processors for <road> nodes."
	date: "$Date: 2007-07-24 11:47:24 +0200 (Tue, 24 Jul 2007) $"
	revision: "$Revision: 901 $"

class
	TRAFFIC_ROAD_NODE_PROCESSOR


inherit
	TRAFFIC_NODE_PROCESSOR
		redefine
			process_subnodes
		end

create
	make

feature -- Access

	Name: STRING = "road"
			-- Name of element to process

	Mandatory_attributes: ARRAY [STRING]
			-- Table of mandatory attributes
		do
			Result := << "id", "from", "to", "direction", "type" >>
			Result.compare_objects
		end

feature -- Basic operations

	process
			-- Process node.
		local
			road: TRAFFIC_ROAD
			p: DS_ARRAYED_LIST [TRAFFIC_POINT]
		do
			if not has_attribute ("id") then
				set_error (Mandatory_attribute_missing, <<"id">>)
			elseif not has_attribute ("from") then
				set_error (Mandatory_attribute_missing, <<"from">>)
			elseif not has_attribute ("to") then
				set_error (Mandatory_attribute_missing, <<"to">>)
			elseif not has_attribute ("direction") then
				set_error (Mandatory_attribute_missing, <<"direction">>)
			elseif not has_attribute ("type") then
				set_error (Mandatory_attribute_missing, <<"type">>)
			elseif not city.stations.has (xml_attribute ("from")) then
				set_error (Unknown_source, <<xml_attribute ("from")>>)
			elseif not city.stations.has (xml_attribute ("to")) then
				set_error (Unknown_destination, << xml_attribute ("to")>> )
			else
				map_factory.build_road (( xml_attribute ("from")), ( xml_attribute ("to")), city, ( xml_attribute ("type")), ( xml_attribute ("id")),( xml_attribute ("direction")))
				road := map_factory.road
				if not has_error and has_subnodes then
					process_subnodes
				end
				if not has_error and polypoints.count >= 2 then
					road.one_way.set_polypoints (polypoints)
					if xml_attribute ("direction").is_equal ("undirected") then
						create p.make (polypoints.count)
						from
							polypoints.start
						until
							polypoints.off
						loop
							p.put_first (create{ TRAFFIC_POINT}.make_from_other (polypoints.item_for_iteration))
							polypoints.forth
						end
						road.other_way.set_polypoints (p)
					end
					-- adjust the positions of the start and end station of this link
					adjust_location (road.one_way, polypoints)
				end
			end
		end

	process_subnodes
			-- Process subnodes.
		local
			n: XM_ELEMENT
			p: TRAFFIC_NODE_PROCESSOR
			location: TRAFFIC_POINT
		do
			create polypoints.make (0)
			from
				subnodes.start
			until
				has_error or subnodes.after
			loop
				location := Void
				n := subnodes.item
				if has_processor (n.name) then
					p := processor (n.name)
				else
					set_error (Unknown_subnode, << p.name >>)
				end
				if not has_error then
					p.set_source (n)
					p.set_parent (Current)
					if has_target then
						p.set_target (target)
					end
					if not p.has_error then
						p.process
						-- Has a point been generated?
						location ?= data
						if location /= Void then
							polypoints.force_last (location)
						end
					else
						set_error (p.error_code, p.slots)
					end
				end
				subnodes.forth
			end
		end

feature {NONE} -- Implementation

	polypoints: DS_ARRAYED_LIST [TRAFFIC_POINT]
			-- Polypoints of this link


	zero_vector: TRAFFIC_POINT
		once
			Result := create {TRAFFIC_POINT}.make (0, 0)
		end

	adjust_location (road: TRAFFIC_ROAD_SEGMENT; a_polypoints: DS_LIST [TRAFFIC_POINT])
			-- Adjust positions
		do
			if road.origin.location = Void or equal(road.origin.location, zero_vector) then
				road.origin.set_location
					(create {TRAFFIC_POINT}.make (a_polypoints.first.x, a_polypoints.first.y))
			else
				road.origin.set_location
					(create {TRAFFIC_POINT}.make (	(road.origin.location.x + a_polypoints.first.x)/ 2.0,
												(road.origin.location.y + a_polypoints.first.y)/ 2.0))
			end
			if road.destination.location = Void or equal(road.destination.location, zero_vector) then
				road.destination.set_location
					(create {TRAFFIC_POINT}.make (a_polypoints.last.x, a_polypoints.last.y))
			else
				road.destination.set_location
					(create {TRAFFIC_POINT}.make (	(road.destination.location.x + a_polypoints.last.x)/ 2.0,
												(road.destination.location.y + a_polypoints.last.y)/ 2.0))
			end
		end
end
