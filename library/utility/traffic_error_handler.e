indexing

	description: "[

		Error message handler

	]"
	date: "$Date$"
	revision: "$Revision$"

class
	TRAFFIC_ERROR_HANDLER

inherit

	TRAFFIC_ERROR_CODES

	TRAFFIC_ERROR_MESSAGES
		export {NONE} all end

	EXCEPTIONS
		export
			{NONE} all
			{ANY} die
		end

create

	make

feature {NONE} -- Initialization

	make is
			-- Create an error handler instance
		do
			is_verbose := True
			clear_last_error
		ensure
			last_error_code_zero: last_error_code = 0
			last_error_message_empty: last_error_message.is_empty
		end

feature -- Access

	last_error_code: INTEGER
			-- Integer representation of last error occured

	last_error_message: STRING
			-- Message of last error

feature -- Status report

	is_verbose: BOOLEAN
			-- Is error handler printing error messages?

	has_error_occured: BOOLEAN is
			-- True if `last_error_code' /= 0
		do
			Result := last_error_code /= 0
		end

feature -- Status setting

	set_verbose (a_value: like is_verbose) is
			-- Set `is_verbose' to `a_value'.
		do
			is_verbose := a_value
		ensure
			is_verbose_set: is_verbose = a_value
		end

feature -- Element change

	set_error (an_error_code: like last_error_code) is
			-- Set `last_error_code' to `an_error_code'.
		do
			last_error_code := an_error_code
			last_error_message := ""
		ensure
			error_set: last_error_code = an_error_code
			error_occured: has_error_occured
		end

feature -- Basic operations

	clear_last_error is
			-- Clear `last_error_code' and `last_error_message'.
		do
			last_error_code := 0
			last_error_message := ""
		ensure
			last_error_code_zero: last_error_code = 0
			last_error_message_empty: last_error_message.is_empty
			error_cleared: not has_error_occured
		end

	raise_warning (an_error_code: INTEGER; error_data: TUPLE []) is
			-- Set `last_error' to `error_code' and display an error message.
		do
			last_error_code := an_error_code
			if error_data = Void then
				last_error_message := generate_message (an_error_code, [])
			else
				last_error_message := generate_message (an_error_code, error_data)
			end
			if is_verbose then
				io.error.put_string ("Warning "+an_error_code.out+": "+last_error_message+"%N")
				io.error.flush
			end
			print_to_error_log_file ("Warning "+an_error_code.out+": "+last_error_message, True)
		ensure
			error_set: last_error_code = an_error_code
			error_message_set: not last_error_message.is_empty
		end

	raise_error (an_error_code: INTEGER; error_data: TUPLE []) is
			-- Set `last_error' to `error_code', display an error message and raise developer exception.
		do
			last_error_code := an_error_code
			if error_data = Void then
				last_error_message := generate_message (an_error_code, [])
			else
				last_error_message := generate_message (an_error_code, error_data)
			end
			if is_verbose then
				io.error.put_string ("Error "+an_error_code.out+": "+last_error_message+"%N")
				io.error.flush
			end
			print_to_error_log_file ("Error "+an_error_code.out+": "+last_error_message, True)
			io.error.put_string ("Error occurred, please consult "+Error_log_file_name.out+" for a trace.%N")
		ensure
			error_set: last_error_code = an_error_code
			error_message_set: not last_error_message.is_empty
		end

feature {NONE} -- Implementation

	generate_message (an_error_code: INTEGER; error_data: TUPLE []): STRING is
			-- Generate message for `an_error_code' and use `error_data' to fill placeholders in the error message.
		require
			error_data_not_void: error_data /= Void
		local
			a_message: STRING
			i: INTEGER
		do
			if Error_messages.has (an_error_code) then
				a_message := Error_messages.item (an_error_code)
			else
				a_message := Default_error_message
			end

			create Result.make_from_string (a_message)
			Result.replace_substring_all ("{0}", an_error_code.out)
			from i := 1 until i > error_data.count loop
				Result.replace_substring_all ("{"+i.out+"}", error_data.item (i).out)
				i := i + 1
			end
		ensure
			generated_message_not_void: Result /= Void
		end

	print_to_error_log_file (a_message: STRING; prepend_date: BOOLEAN) is
			-- Print `a_message' to error log file.
		local
			clock: DT_SYSTEM_CLOCK
		do
			Error_log_file.open_append
			if Error_log_file.is_open_write then
				if prepend_date then
					create clock.make
					Error_log_file.put_string (clock.date_time_now.out+" - "+a_message)
				else
					Error_log_file.put_string (a_message)
				end
				Error_log_file.put_new_line
				Error_log_file.close
			end
		end

	Error_log_file_name: STRING is "error.txt"
			-- Name of error log file

	Error_log_file: KL_TEXT_OUTPUT_FILE is
			-- Error log file
		local
			alredy_exists: BOOLEAN
		once
			create Result.make (Error_log_file_name)
			alredy_exists := Result.exists
			Result.open_append
			if Result.is_open_write and alredy_exists then
				Result.put_string ("------%N")
			end
			Result.close
		ensure
			error_log_file_not_void: Result /= Void
		end


end
