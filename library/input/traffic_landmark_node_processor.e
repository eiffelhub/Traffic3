note
	description: "Objects that ..."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	TRAFFIC_LANDMARK_NODE_PROCESSOR

inherit
	TRAFFIC_NODE_PROCESSOR
		redefine
			process_subnodes
		end

create
	make

feature -- Access

	Name: STRING = "landmark"
			-- Name of node to process

	station: TRAFFIC_STATION
			-- Reference to node

	Mandatory_attributes: ARRAY [STRING]
			-- Table of mandatory attributes
		once
			Result := << "name", "x", "y", "filename">>
			Result.compare_objects
		end

feature -- Basic operations

	process 
			-- Process node.
		do
			if not has_attribute ("name") then
				set_error (Mandatory_attribute_missing, << "name" >>)
			elseif map_factory.city.landmarks.has (xml_attribute ("name")) then
				set_error (Duplicate_name, << xml_attribute ("name") >>)
			elseif not has_attribute ("x") or not has_attribute ("y") then
				set_error (mandatory_attribute_missing, << "x or y" >>)
			elseif not has_attribute ("filename") then
				set_error (mandatory_attribute_missing, << "x or y" >>)
			elseif not is_attribute_integer ("x") or not is_attribute_integer ("y") then
				set_error (invalid_attribute_value, <<"x or y">>)
			else
				map_factory.build_landmark (attribute_integer ("x"), attribute_integer ("y"), xml_attribute ("name"), city, File_system.pathname_from_file_system (xml_attribute ("filename"), Windows_file_system))
				set_target (map_factory.landmark)
			end

			if has_subnodes then
				process_subnodes
			end
		end

	process_subnodes
			-- Process subnodes.
		local
			n: XM_ELEMENT
			p: TRAFFIC_NODE_PROCESSOR
			f: TRAFFIC_FILE_NODE_PROCESSOR
			files: LINKED_LIST [STRING]
			description: STRING
			info: TRAFFIC_STATION_INFORMATION
		do
			create files.make
			from
				subnodes.start
			until
				has_error or subnodes.after
			loop
				n := subnodes.item
				if has_processor (n.name) then
					p := processor (n.name)
				else
					set_error (Unknown_subnode, << p.name >>)
				end
				if not has_error then
					p.set_source (n)
					p.set_parent (Current)
					if has_target then
						p.set_target (target)
					end
					if not p.has_error then
						p.process
						-- Has a file been generated?
						f ?= p
						if f /= Void then
							files.extend (f.file)
						end
						description ?= data
					else
						set_error (p.error_code, p.slots)
					end
				end
				subnodes.forth
			end
			if files.count > 0 or description /= Void then
				create info.make
				info.set_description (description)
				from
					files.start
				until
					files.after
				loop
					info.extend_picture (files.item)
					files.forth
				end
--				map_factory.station.set_information (info)
			end
		end

end
