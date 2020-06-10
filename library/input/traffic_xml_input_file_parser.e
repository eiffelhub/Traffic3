note
	description: "Parser for XML input files."
	date: "$Date: 2007-09-24 11:12:13 +0200 (Пн, 24 сен 2007) $"
	revision: "$Revision: 931 $"

deferred class
	TRAFFIC_XML_INPUT_FILE_PARSER

inherit
	TRAFFIC_PARSE_ERROR_CONSTANTS
		redefine
			error_description, has_error
		end

	KL_SHARED_FILE_SYSTEM

feature {NONE} -- Initialization

	make
			-- Create parser.
		do
			xml_parser := new_xml_parser
			create tree_pipe.make
			xml_parser.set_string_mode_mixed
			xml_parser.set_callbacks (tree_pipe.start)
			xml_parser.set_resolver (create {XM_FILE_EXTERNAL_RESOLVER}.make)
		ensure
			xml_parser_exists: xml_parser /= Void
			tree_pipe_exists: tree_pipe /= Void
		end

feature -- Access

	xml_document: XM_DOCUMENT
			-- Parsed XML document
		require
			parsed: is_parsed
		do
			Result := tree_pipe.document
		ensure
			Result_exists: Result /= Void
		end

	root_element: XM_ELEMENT
			-- Root element of document
		require
			parsed: is_parsed
		do
			Result := xml_document.root_element
		ensure
			Result_exists: Result /= Void
		end

	error_description: STRING
			-- Description of last parser error
		do
			if error_code > 0 then
				Result := Precursor
			else
				Result := xml_parser.last_error_extended_description
			end
		ensure then
			Result_exists: Result /= Void
			Result_not_empty: not Result.is_empty
		end

feature -- Status report

	has_error: BOOLEAN
			-- Did a parser error occur?
		do
			Result := Precursor or not xml_parser.is_correct
		end

	is_parsed: BOOLEAN
			-- Has a map been parsed?

	has_file_name: BOOLEAN
			-- Has a file name been set?
		do
			Result := file_name /= Void and then not file_name.is_empty
		end

	can_process: BOOLEAN
			-- Can document tree be processed?
		deferred
		end

feature -- Status setting

	set_file_name (a_name: STRING)
			-- Set file name to `a_name'.
		require
			file_name_valid:  File_system.is_file_readable (a_name)
			file_exists: File_system.file_exists (a_name)
		do
			directory_name := file_system.absolute_parent_directory (a_name)
			file_name := file_system.basename (a_name)
			is_parsed := False
		ensure
			file_name_set: has_file_name
			not_parsed: not is_parsed
		end

feature -- Basic operations

	parse
			-- Parse map.
		require
			file_name_set: has_file_name
		local
			file: KL_TEXT_INPUT_FILE
			execution_environment: EXECUTION_ENVIRONMENT
			my_dir: STRING
		do
			create execution_environment
			old_working_directory := execution_environment.current_working_directory
			execution_environment.change_working_directory (directory_name)
			my_dir := execution_environment.current_working_directory
			set_error (0, << >>)
			create file.make (file_name)
			file.open_read
			if file.is_open_read then
				xml_parser.parse_from_stream (file)
				file.close
				if not has_error then
					is_parsed := True
	 			end
			else
				set_error (File_not_readable, << File_system.basename (file_name) >>)
			end
			execution_environment.change_working_directory (old_working_directory)
		ensure
			parsed_if_no_error: not has_error implies is_parsed
		end

	process
			-- Process document tree.
		require
			processing_ready: can_process
		deferred
		end

feature {NONE} -- Implementation

	xml_parser: XM_PARSER
			-- XML parser

	tree_pipe: XM_TREE_CALLBACKS_PIPE
			-- Tree generating callbacks

	new_xml_parser: XM_PARSER
			-- Create new parser
		local
			factory: XM_EXPAT_PARSER_FACTORY
		do
			create factory
			if factory.is_expat_parser_available then
				Result := factory.new_expat_parser
			else
				create {XM_EIFFEL_PARSER} Result.make
			end
		end

	old_working_directory: STRING
			-- Old working directory

invariant

	xml_parser_exists: xml_parser /= Void
	tree_pipe_exists: tree_pipe /= Void
	has_error_definition: has_error = ((error_code > 0) or
			not xml_parser.is_correct)
	has_file_name_definition: has_file_name = (file_name /= Void and then
			not file_name.is_empty)
	parsed_constraint: is_parsed implies has_file_name

end

