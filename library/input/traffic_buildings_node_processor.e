note
	description: "XML processors for <buildings> nodes."
	date: "$Date$"
	revision: "$Revision$"

class
	TRAFFIC_BUILDINGS_NODE_PROCESSOR

obsolete "Needs reworking"

inherit
	TRAFFIC_NODE_PROCESSOR

create
	make

feature -- Access

	Name: STRING = "buildings"
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
		do
			if has_subnodes then
				process_subnodes
			end
		end

end
