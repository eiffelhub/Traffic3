note
	description: "[

		Provide mapping of error constants from EM_ERROR_CODES to string messages.
		
		Placeholders are marked with '{#}' where '#' is the number of replacement.
		Zero is always the error code. 1, 2, etc. are indexes in the error data tuple.

	]"
	date: "$Date$"
	revision: "$Revision$"

class
	TRAFFIC_ERROR_MESSAGES

inherit

	TRAFFIC_ERROR_CODES
		export {NONE} all end

feature {NONE} -- Initialisation

	make_default_messages
			-- Initialise default error messages.
		do

			-- Map loading error messages
			Error_messages.force ("Directory {1} does not exist", Traffic_error_directory_does_not_exist)
			Error_messages.force ("Xml file {1} does not exist", Traffic_error_xml_file_does_not_exist)
			Error_messages.force ("Dump file loading {1} did not work", Traffic_error_loading_dump_file)

			-- Todo add other errors

			-- Miscellaneous error messages
			Error_messages.force ("A 'this should never happen' error has occured in section '{1}'. Please notify the developers", Traffic_error_this_should_never_happen)
		end

feature -- Access

	Error_messages: DS_HASH_TABLE [STRING, INTEGER]
			-- Table which maps error codes to error messages.
		once
			create Result.make (100)
			make_default_messages
		ensure
			error_messages_not_void: Result /= Void
		end

	Default_error_message: STRING
			-- Message of errors whitout specialized message
		once
			Result := "Errorcode '{0}' - See traffic.tr_util.TRAFFIC_ERROR_CODES for more information"
		ensure
			default_error_message_not_void: Result /= Void
		end

end
