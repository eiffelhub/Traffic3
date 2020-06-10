note
	description: "XML processors for background <file> elements."
	date: "$Date: 2009-04-06 14:42:41 +0200 (Пн, 06 апр 2009) $"
	revision: "$Revision: 1086 $"

class
	TRAFFIC_FILE_NODE_PROCESSOR

inherit
	TRAFFIC_NODE_PROCESSOR

create
	make

feature -- Access

	Name: STRING = "file"
			-- Name of element to process

	Mandatory_attributes: ARRAY [STRING]
			-- Table of mandatory attributes
		once
			Result := << "name" >>
			Result.compare_objects
		end

feature -- Basic operations

	process 
			-- Process node.
		do
			if has_attribute ("name") then
				create file.make_from_string (xml_attribute ("name"))
--				parent.send_data (file)
			else
				set_error (Mandatory_attribute_missing, << "name" >>)
			end
		end

	file: STRING
			-- String in which the filename is stored

end
