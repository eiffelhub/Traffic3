note
	description: "XML processors for <line section> nodes."
	date: "$Date: 2009-08-21 13:35:22 +0200 (Пт, 21 авг 2009) $"
	revision: "$Revision: 1098 $"

class
	TRAFFIC_LINE_SECTION_NODE_PROCESSOR

inherit
	TRAFFIC_NODE_PROCESSOR
		redefine
			process_subnodes
		end

create
	make

feature -- Access

	Name: STRING = "line_section"
			-- Name of element to process

	Mandatory_attributes: ARRAY [STRING]
			-- Table of mandatory attributes
		do
			Result := << "from", "to", "direction" >>
			Result.compare_objects
		end

feature -- Basic operations

	process
			-- Process node.
		local
			line: TRAFFIC_LINE
			polypoints_other_direction: DS_ARRAYED_LIST [TRAFFIC_POINT]
			line_section_one_direction, line_section_other_direction: TRAFFIC_LINE_SEGMENT
		do
			if not has_error then
				line ?= parent.target
				if not has_attribute ("from") then
					set_error (Mandatory_attribute_missing, <<"from">>)
				elseif not has_attribute ("to") then
					set_error (Mandatory_attribute_missing, <<"to">>)
				elseif not city.stations.has (xml_attribute ("from")) then
					set_error (Unknown_source, <<xml_attribute ("from")>>)
				elseif not city.stations.has (xml_attribute ("to")) then
					set_error (Unknown_destination, << xml_attribute ("to")>> )
				elseif line = Void then
					set_error (Missing_line, << >> )
				elseif not city.lines.has (line.name) then
					set_error (Unknown_line, << line.name >>)
				else
					if not has_error and has_subnodes then
						process_subnodes
					end
					if polypoints.count >= 2 then
						create polypoints_other_direction.make (0)
						from
							polypoints.finish
						until
							polypoints.before
						loop
							polypoints_other_direction.force_last (polypoints.item_for_iteration.twin)
							polypoints.back
						end
					else
						polypoints := Void
						polypoints_other_direction := Void
					end
					if has_attribute ("direction") and then xml_attribute ("direction").is_equal ("undirected") then
							map_factory.build_line_segment (( xml_attribute ("from")), ( xml_attribute ("to")), polypoints, city, line)
							line_section_one_direction := map_factory.connection_one_direction
							line_section_other_direction := map_factory.connection_other_direction
							map_factory.connection_other_direction.set_polypoints (polypoints_other_direction)
					else -- directed
						set_error (Invalid_line_section, << line.name, xml_attribute ("from"), xml_attribute ("to") >>)
					end
					set_target (line_section_one_direction)
				end


				if not has_error and roads.count >= 1 then
					line_section_one_direction.set_roads(roads)
					if line_section_other_direction /= Void then
						line_section_other_direction.set_roads(roads)
					end
				end
			end
		end

	process_subnodes 
			-- Process subnodes.
		local
			n: XM_ELEMENT
			p: TRAFFIC_NODE_PROCESSOR
			location: TRAFFIC_POINT
			road: TRAFFIC_ROAD_SEGMENT
		do
			create polypoints.make (0)
			create roads.make(0)
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
						-- Has a road been generated?
						road ?= data
						if road /= Void then
							roads.extend (road)
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

	roads: ARRAYED_LIST[TRAFFIC_ROAD_SEGMENT]
			-- Roads of this line_section

end
