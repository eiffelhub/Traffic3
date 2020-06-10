note
	description: "[
		XML processors for <point> elements. Example: <point x="3.2" y="1.7">.
		]"
	date: "$Date: 2008-09-09 11:36:48 +0200 (Вт, 09 сен 2008) $"
	revision: "$Revision: 1070 $"

class
	TRAFFIC_POINT_NODE_PROCESSOR

inherit
	TRAFFIC_NODE_PROCESSOR

create
	make

feature -- Access

	Name: STRING = "point"
			-- Name of node to process

	Mandatory_attributes: ARRAY [STRING]
			-- Table of mandatory attributes
		once
			Result := << "x", "y" >>
			Result.compare_objects
		end

feature -- Basic operations

	process 
			-- Process node.
		local
			x: INTEGER
			y: INTEGER
			p: TRAFFIC_POINT
		do
			if not has_attribute ("x") and has_attribute ("y") then
				set_error (Mandatory_attribute_missing, << "x", "y" >>)
			elseif not ((is_attribute_integer ("x") and is_attribute_integer ("y")) or
					(is_attribute_double ("x") and is_attribute_double ("y")))
			then
				set_error (Wrong_attribute_type, << "x", "y" >>)
			else
				x := attribute_integer ("x")
				y := attribute_integer ("y")
				create p.make(x, y)
				parent.send_data (p)
			end
		end

end
