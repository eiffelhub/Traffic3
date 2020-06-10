note
	description: "Loader that handles the city loading from xml and dump files"
	date: "$Date$"
	revision: "$Revision$"

class
	TRAFFIC_MAP_LOADER

inherit

	KL_SHARED_FILE_SYSTEM

	TRAFFIC_SHARED_ERROR_HANDLER

	EXCEPTIONS

create
	make

feature -- Initialization

	make (a_filename: STRING)
			-- Sets all necessary pathnames if the directory and the xml-file specified by `a_filename' exists.
		require
			a_filename_exists: a_filename /= Void
		do
			if not file_system.directory_exists (file_system.absolute_parent_directory (a_filename)) then
				error_handler.raise_warning (error_handler.traffic_error_directory_does_not_exist, [file_system.absolute_parent_directory (a_filename)])
				has_error := True
			elseif not file_system.file_exists (a_filename) then
				error_handler.raise_warning (error_handler.traffic_error_xml_file_does_not_exist, [a_filename])
				has_error := True
			else
				directory_name := file_system.dirname (a_filename)
				xml_filename := a_filename
				dump_filename := file_system.pathname (directory_name, file_system.basename (xml_filename).split('.')[1] + ".dump")
				log_filename := file_system.pathname (directory_name, "dump.log")
				has_error := False
			end
			enable_dump_loading
		ensure
			dump_loading_enabled: is_dump_loading_enabled
		end

feature -- Basic operations

	load_map
			-- Load map if available from dump file, else from xml file.
			-- If map loading was unsuccessful, has_error will be set to `True'.
		local
			directory: DIRECTORY
			log_file: RAW_FILE
		do
			if not has_error then
				if is_dump_loading_enabled then
					-- Check whether there is a dump.log file and create it if there is none
					create directory.make_open_read (directory_name)
					if not directory.has_entry (file_system.basename (log_filename)) then
						create log_file.make_create_read_write (log_filename)
					end

					-- Get map
					if is_dump_up_to_date then
						get_from_dump
					else
						get_from_xml
					end
				else
					get_from_xml
				end
			end
		end

feature -- Status report

	is_dump_loading_enabled: BOOLEAN
			-- Can the map be loaded from the dump?

	has_error: BOOLEAN
			-- Did the map loading succeed?

feature -- Status setting

	enable_dump_loading
			-- Set `is_dump_loading_enabled' to `True'.
		do
			is_dump_loading_enabled := True
		ensure
			dump_loading_enabled: is_dump_loading_enabled
		end

	disable_dump_loading
			-- Set `is_dump_loading_enabled' to `False'.
		do
			is_dump_loading_enabled := False
		ensure
			dump_loading_disabled: not is_dump_loading_enabled
		end

feature -- Access

	city: TRAFFIC_CITY
			-- City retrieved from loading

feature {NONE} -- Implementation

	log_filename: STRING
			-- Location of the log-File for the dumps

	directory_name: STRING
			-- Directory of all the map files

	xml_filename: STRING
			-- Location of the xml-File

	dump_filename: STRING
			-- Location of the dump-File

	get_from_xml
			-- Initialize with map loaded from file with `a_filename'.
			-- (either `a_filename' is an absolute path
			--  or relative to current working directory)
		require
			xml_file_exists: xml_filename /= Void and then file_system.file_exists (xml_filename)
		local
			factory: TRAFFIC_MAP_FACTORY
			map_parser: TRAFFIC_MAP_PARSER
		do
			create factory.make
			create map_parser.make_with_factory (factory)
			map_parser.set_file_name (xml_filename)
			map_parser.parse
			if map_parser.can_process then
				map_parser.process
			end
			if map_parser.has_error then
				has_error := True
				raise ("Error while parsing " + xml_filename + ": " + map_parser.error_description)
			else
				city := factory.city
				city.recalculate_weights_and_connect_stops
				has_error := False
				create_dump
			end
		end

	get_from_dump
			-- Getting the dumped map
		require
			dump_file_exists: dump_filename /= Void and then file_system.file_exists (dump_filename)
		local
			directory: DIRECTORY
		do
			create directory.make_open_read (directory_name)
			if directory.has_entry (file_system.basename (dump_filename)) then
				city ?= (create {TRAFFIC_CITY}.make("temp")).retrieve_by_name (dump_filename)
				has_error := False
			else
				city := void
				has_error := True
			end
		rescue
			has_error := True
			get_from_xml
			retry
		end

	is_dump_up_to_date: BOOLEAN
			-- Is the dump file up to date?
		require
			log_file_exists: log_filename /= Void and then file_system.file_exists (log_filename)
			xml_file_exists: xml_filename /= Void and then file_system.file_exists (xml_filename)
		local
			log_file: RAW_FILE
			xml_file: RAW_FILE
			stamp: INTEGER
			name: STRING
		do
			create log_file.make_open_read (log_filename)
			create xml_file.make (xml_filename)
			Result := False
			from
				log_file.start
			until
				log_file.off
			loop
				log_file.read_word
				name := log_file.last_string
				if not name.is_equal ("") then
					log_file.read_character
					log_file.read_integer
					stamp := log_file.last_integer
				end
				if name.is_equal (file_system.basename (xml_filename)) and stamp = xml_file.date then
					Result := True
				end

			end
			log_file.close
		end

	create_dump
			-- Write map to dump file.
		require
			dump_file_exists: dump_filename /= Void and then not dump_filename.is_empty
		local
			log_file: RAW_FILE
			xml_file: RAW_FILE
		do
			city.store_by_name (dump_filename)
			create log_file.make_open_append (log_filename)
			create xml_file.make(xml_filename)
			log_file.finish
			log_file.putstring (file_system.basename (xml_filename) + " ")
			log_file.putint (xml_file.date)
			log_file.close
		end

end
