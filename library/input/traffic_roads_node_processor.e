note
	description: "XML processors for <roads> elements."
	date: "$Date: 2007-07-24 11:47:24 +0200 (Tue, 24 Jul 2007) $"
	revision: "$Revision: 901 $"

class
	TRAFFIC_ROADS_NODE_PROCESSOR

inherit
	TRAFFIC_NODE_PROCESSOR

create
	make

feature -- Access

	Name: STRING = "roads"
			-- Name of node to process

	Mandatory_attributes: ARRAY [STRING]
			-- Table of mandatory attributes
		once
			Result := {ARRAY [STRING]}<< >>
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
