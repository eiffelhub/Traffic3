indexing
	description:"Error constants used for XML parsing."
	date: "$Date: 2007-09-24 11:12:13 +0200 (Пн, 24 сен 2007) $"
	revision: "$Revision: 931 $"

class
	TRAFFIC_PARSE_ERROR_CONSTANTS

inherit
	TRAFFIC_ERROR_CONSTANTS

feature {NONE} -- Access

	error_text (a_code: INTEGER): STRING is
			-- Raw error text for error `a_code'
		do
			inspect
				a_code
			when Unknown_subnode then
				Result := "Unknown subnode <$>"
			when Mandatory_attribute_missing then
				Result := "Mandatory attribute <$> missing"
			when Unknown_node_processor then
				Result := "Unknown node processor '$'"
			when Wrong_attribute_type then
				Result := "Wrong attribute type <$>"
			when Wrong_property_value then
				Result := "Wrong property value '$'"
			when Incorrect_property then
				Result := "Incorrect property <$>"
			when Unknown_source then
				Result := "Unknown source '$'"
			when Unknown_destination then
				Result := "Unknown destination '$'"
			when Unknown_line then
				Result := "Unknown line '$'"
			when Missing_line then
				Result := "Missing line"
			when Duplicate_name then
				Result := "Name '$' is already registered"
			when Invalid_line_section then
				Result := "Unacceptable line_section: Line: '$', src: '$', dest: '$'"
			when Invalid_option then
				Result := "Invalid option '$'"
--			when Unknown_station then
--				Result := "Unknown station '$'"
			when Unknown_route_type then
				Result := "Unknown route type '$'"
			when Wrong_color_value then
				Result := "Wrong color value ($)"
			when File_not_readable then
				Result := "File '$' cannot be read"
			when Invalid_file_name then
				Result := "Invalid file name '$'"
			when Wrong_position then
				Result := "No or invalid point"
			when Invalid_parent_node then
				Result := "Invalid parent node <$>"
			when Invalid_attribute_value then
				Result := "Invalid attribute value '$'"
			when Too_few_points then
				Result := "Not enough points defined for line section"
			when Mandatory_subnode_missing then
				Result := "Mandatory subnode <$> missing"
			when No_road_with_given_id_exists then
				Result := "No road with given id exists"
			else
				Result := "Unknown error"
			end
		end

feature {NONE} -- Constants

	Unknown_subnode: INTEGER is 1

	Mandatory_attribute_missing: INTEGER is 2

	Unknown_node_processor: INTEGER is 3

	Wrong_attribute_type: INTEGER is 4

	Wrong_property_value: INTEGER is 5

	Incorrect_property: INTEGER is 6

	Unknown_source: INTEGER is 7

	Unknown_destination: INTEGER is 8

	Unknown_line: INTEGER is 9

	Missing_line: INTEGER is 10

	Duplicate_name: INTEGER is 11

	Invalid_line_section: INTEGER is 12

	Invalid_option: INTEGER is 13

--	Unknown_station: INTEGER is 14

	Unknown_route_type: INTEGER is 15

	Wrong_color_value: INTEGER is 16

	File_not_readable: INTEGER is 17

	Invalid_file_name: INTEGER is 18

	Wrong_position: INTEGER is 19

	Invalid_parent_node: INTEGER is 20

	Invalid_attribute_value: INTEGER is 21

	Invalid_incoming_line_section: INTEGER is 22

	Invalid_outgoing_line_section: INTEGER is 23

	Duplicate_id: INTEGER is 24

	Too_few_points: INTEGER is 25

	Mandatory_subnode_missing: INTEGER is 26

	No_road_with_given_id_exists: INTEGER is 27

end

