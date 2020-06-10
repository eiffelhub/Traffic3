note
	description: "Objects that ..."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	TRAFFIC_POLYGON_NODE_PROCESSOR

inherit
	TRAFFIC_NODE_PROCESSOR
		redefine
			 process_subnodes
		end

create
	make

feature -- Access

	Name: STRING = "polygon"
			-- Name of node to process

	Mandatory_attributes: ARRAY [STRING]
			-- Table of mandatory attributes
		once
			Result := << >>
			Result.compare_objects
		end

feature -- Basic operations

	process
			-- Process node.
		local
			polygon: TRAFFIC_POLYGON
		do
			if has_subnodes then
				process_subnodes
			end
			if not has_error then
				if polypoints.count < 2 then
					set_error (Too_few_points, << "polygon" >>)
				elseif color = Void then
					set_error (Mandatory_subnode_missing, << "color" >>)
				end
			end
			if not has_error and polypoints.count >= 2 and color /= Void then
				create polygon.make (polypoints, color)
				city.background_polygons.extend (polygon)
			else
				set_error (Too_few_points, << "polygon" >>)
			end
		end

	process_subnodes
			-- Process subnodes.
		local
			n: XM_ELEMENT
			p: TRAFFIC_NODE_PROCESSOR
			a_location: TRAFFIC_POINT
			location: REAL_COORDINATE
			a_color: TRAFFIC_COLOR
			i: INTEGER
			a_polypoints: ARRAY [REAL_COORDINATE]
		do
			create a_polypoints.make (1,100)
			from
				subnodes.start
				i := 1
			until
				has_error or subnodes.after or i > 100
			loop
				a_location := Void
				a_color := Void
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
						-- Either a point or a color has been generated
						a_location ?= data
						a_color ?= data
						if a_location /= Void then
							create location.make (a_location.x, a_location.y)
							a_polypoints.put (location, i)
							i := i + 1
						elseif a_color /= Void then
							color := a_color
						end
					else
						set_error (p.error_code, << >>)
					end
				end
				subnodes.forth
			end
			create polypoints.make (1, i-1)
			polypoints := a_polypoints.subarray (1, i-1)
		end

feature {NONE} -- Implementation

	polypoints: ARRAY [REAL_COORDINATE]
			-- Polypoints for the polygon

	color: TRAFFIC_COLOR
			-- Color of the polygon

end -- class TRAFFIC_POLYGON_NODE_PROCESSOR
