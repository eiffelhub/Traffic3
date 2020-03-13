indexing
	description: "Error codes that may occur in Traffic"
	date: "$Date$"
	revision: "$Revision$"

class
	TRAFFIC_ERROR_CODES

feature -- Map loading

	Traffic_error_xml_file_does_not_exist: INTEGER is 101
	
	Traffic_error_directory_does_not_exist: INTEGER is 102
	
	Traffic_error_loading_dump_file: INTEGER is 103

feature -- Miscellaneous

	Traffic_error_this_should_never_happen: INTEGER is 9003
			-- An error in a code section which shouldn't have been executed
	
end
