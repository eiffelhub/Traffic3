note
	description: "XML processors for <lines> nodes."
	date: "$Date: 2007-09-24 11:12:13 +0200 (Пн, 24 сен 2007) $"
	revision: "$Revision: 931 $"

class
	TRAFFIC_LINES_NODE_PROCESSOR

inherit
	TRAFFIC_NODE_PROCESSOR

create
	make

feature -- Access

	Name: STRING = "lines"
			-- Name of node to process

	Mandatory_attributes: ARRAY [STRING]
			-- Table of mandatory attributes
		once
			Result := <<  >>
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
