indexing
	description: "XML processors for <description> nodes."
	date: "$Date: 2009-04-06 14:42:41 +0200 (Пн, 06 апр 2009) $"
	revision: "$Revision: 1086 $"

class
	TRAFFIC_DESCRIPTION_NODE_PROCESSOR

inherit
	TRAFFIC_NODE_PROCESSOR

create
	make

feature -- Access

	Name: STRING is
			-- Name of node to process
		once
			Result := "description"
		end

	Mandatory_attributes: ARRAY [STRING] is
			-- Table of mandatory attributes
		do
			Result := << "text" >>
			Result.compare_objects
		end

feature -- Basic operations

	process is
			-- Process element.
		require else
			has_target: has_target -- Because it has been passed down from the parent.
		local
			description: STRING
		do
			if has_attribute ("text") then
				create description.make_from_string (xml_attribute ("text"))
				parent.send_data (description)
			else
				set_error (Mandatory_attribute_missing, << "text" >>)
			end
		end

end
