note
	description: "XML processors for <onroad> nodes."
	date: "$Date: 2007-07-24 11:47:24 +0200 (Tue, 24 Jul 2007) $"
	revision: "$Revision: 901 $"

class
	TRAFFIC_ONROAD_NODE_PROCESSOR

inherit
	TRAFFIC_NODE_PROCESSOR

create
	make

feature -- Access

	Name: STRING = "onroad"
			-- Name of node to process

	Mandatory_attributes: ARRAY [STRING]
			-- Table of mandatory attributes
		once
			Result := << "id", "back" >>
			Result.compare_objects
		end

feature -- Basic operations

	process 
			-- Process node.
		local
			a_city:TRAFFIC_CITY
		do
			if not has_attribute ("id") then
				set_error (Mandatory_attribute_missing, << "id" >>)
			else
				a_city:=map_factory.city
				-- retrieve the corresponding instance of TRAFFIC_ROAD
				if (a_city.roads.has (xml_attribute("id").to_integer)) and xml_attribute ("back").is_equal ("false") then
					parent.send_data (a_city.roads.item (xml_attribute("id").to_integer).one_way)
				elseif (a_city.roads.has (xml_attribute("id").to_integer)) and xml_attribute ("back").is_equal ("true") then
					parent.send_data (a_city.roads.item (xml_attribute("id").to_integer).other_way)
				else
					set_error(No_road_with_given_id_exists,<<"id">>)
					parent.send_data(Void)
				end
			end

			if not has_error and has_subnodes then
				process_subnodes
			end
		end
end
