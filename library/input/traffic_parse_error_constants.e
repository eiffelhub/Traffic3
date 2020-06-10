note
	description:"Error constants used for XML parsing."
	date: "$Date: 2007-09-24 11:12:13 +0200 (Пн, 24 сен 2007) $"
	revision: "$Revision: 931 $"

class
	TRAFFIC_PARSE_ERROR_CONSTANTS

inherit
	TRAFFIC_ERROR_CONSTANTS

feature {NONE} -- Access

	error_text (a_code: INTEGER): STRING
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

	Unknown_subnode: INTEGER = 1

	Mandatory_attribute_missing: INTEGER = 2

	Unknown_node_processor: INTEGER = 3

	Wrong_attribute_type: INTEGER = 4

	Wrong_property_value: INTEGER = 5

	Incorrect_property: INTEGER = 6

	Unknown_source: INTEGER = 7

	Unknown_destination: INTEGER = 8

	Unknown_line: INTEGER = 9

	Missing_line: INTEGER = 10

	Duplicate_name: INTEGER = 11

	Invalid_line_section: INTEGER = 12

	Invalid_option: INTEGER = 13

--	Unknown_station: INTEGER = 14

	Unknown_route_type: INTEGER = 15

	Wrong_color_value: INTEGER = 16

	File_not_readable: INTEGER = 17

	Invalid_file_name: INTEGER = 18

	Wrong_position: INTEGER = 19

	Invalid_parent_node: INTEGER = 20

	Invalid_attribute_value: INTEGER = 21

	Invalid_incoming_line_section: INTEGER = 22

	Invalid_outgoing_line_section: INTEGER = 23

	Duplicate_id: INTEGER = 24

	Too_few_points: INTEGER = 25

	Mandatory_subnode_missing: INTEGER = 26

	No_road_with_given_id_exists: INTEGER = 27

end

