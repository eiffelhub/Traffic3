note
	description: "XML processors for <map> nodes."
	date: "$Date: 2009-08-21 13:35:22 +0200 (Пт, 21 авг 2009) $"
	revision: "$Revision: 1098 $"

class
	TRAFFIC_MAP_NODE_PROCESSOR

inherit
	TRAFFIC_NODE_PROCESSOR

create
	make

feature -- Access

	Name: STRING = "map"
			-- Name of node to process

	Mandatory_attributes: ARRAY [STRING]
			-- Table of mandatory attributes
		once
			Result := << "name", "scale_factor", "center_x", "center_y", "radius" >>
			Result.compare_objects
		end

feature -- Basic operations

	process 
			-- Process node.
		local
			description: STRING
		do
			if has_attribute ("name") then
				map_factory.build_city (xml_attribute ("name"))
			end

			if has_attribute ("scale_factor") then
				if not xml_attribute ("scale_factor").is_double then
					set_error (wrong_attribute_type, << "scale_factor" >>)
				end
				city.set_scale_factor (xml_attribute ("scale_factor").to_double)
			end

			if has_attribute ("center_x") and has_attribute ("center_y") and has_attribute ("radius") then
				if not xml_attribute ("center_x").is_double then
					set_error (wrong_attribute_type, << "center_x" >>)
				end
				if not xml_attribute ("center_y").is_double then
					set_error (wrong_attribute_type, << "center_y" >>)
				end
				if not xml_attribute ("radius").is_double then
					set_error (wrong_attribute_type, << "radius" >>)
				end
				if not has_error then
					city.set_center (create {TRAFFIC_POINT}.make (attribute_double ("center_x"), attribute_double ("center_y")))
					city.set_radius (attribute_double ("radius"))
				end

			end

			if has_subnodes then
				process_subnodes
			end
			description ?= data
			if not has_error and description /= Void then
				map_factory.city.set_description (description)
			end
		end

end
