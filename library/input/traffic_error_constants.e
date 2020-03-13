note
	description: "Interface for error constant classes."
	date: "$Date: 2009-08-21 13:35:22 +0200 (Пт, 21 авг 2009) $"
	revision: "$Revision: 1098 $"

deferred class
	TRAFFIC_ERROR_CONSTANTS

inherit
	KL_SHARED_FILE_SYSTEM

feature  -- Access

	error_code: INTEGER
			-- Code of error

	file_name: STRING
			-- Name of file where error occurred

	directory_name: STRING
			-- Directory where file is located

	error_description: STRING
			-- Textual description of error
		require
			has_error: has_error
		do
			Result := full_message
		ensure
			Result_exists: Result /= Void
			Result_not_empty: not Result.is_empty
		end

feature {NONE} -- Access

	error_text (a_code: INTEGER): STRING
			-- Raw error text for code `a_code'
		require
			a_code_strictly_positive: a_code > 0
		deferred
		ensure
			Result_exists: Result /= Void
			Result_not_empty: not Result.is_empty
		end

feature -- Status report

	has_error: BOOLEAN
			-- Did an error occur?
		do
			Result := (error_code > 0)
		end

feature {NONE} -- Status report

	is_complete (a_code: INTEGER; an_error_string_array: ARRAY [STRING]): BOOLEAN
			-- Does `an_error_string_error' contain complete info for error `a_code'?
		require
			code_positive: a_code >= 0
			array_exists: an_error_string_array /= Void
		do
			if a_code = 0 then
				Result := an_error_string_array.is_empty
			else
				Result := (an_error_string_array.count >= slot_count (error_text (a_code)))
			end
		end

feature {NONE} -- Status setting

	set_error (a_code: INTEGER; an_error_string_array: ARRAY [STRING])
			-- Set error code to `a_code' and additional information to `an_error_string_array'.
		require
			error_code_positive: a_code >= 0
			array_exists: an_error_string_array /= Void
			complete: is_complete (a_code, an_error_string_array)
		do
			error_code := a_code
			slots := an_error_string_array
		ensure
			error_code_set: error_code = a_code
			slots_set: slots = an_error_string_array
		end

	reset_error
			-- Reset error code.
		do
			error_code := 0
			slots := Void
		ensure
			no_error: not has_error
			no_slots: slots = Void
		end

feature {NONE} -- Constants

	Slot_character: CHARACTER = '$'
			-- Character that represents an information slot

feature {TRAFFIC_ERROR_CONSTANTS} -- Implementation

	slots: ARRAY [STRING]
			-- Slots for additional information

feature {NONE} -- Implementation

	slot_count (a_string: STRING): INTEGER
			-- Number of information slots in error string `a_string'
		require
			string_exists: a_string /= Void
		do
			Result := a_string.occurrences (Slot_character)
		ensure
			Result_positive: Result >= 0
		end

	full_message: STRING 
			-- Full error message with filled in information slots
		require
			has_error: has_error
		local
			i: INTEGER
			pos: INTEGER
			c: INTEGER
			s: STRING
		do
			Result := (error_text (error_code)).twin
			c := slot_count (Result)
			if file_name /= Void then
				Result.prepend (File_system.basename (file_name) + ": ")
			end

			from
				i := slots.lower
			until
				i = slots.lower + c
			loop
				pos := Result.index_of (Slot_character, 1)
					check
						character_found: pos > 0
							-- Because there is still an unfilled information
							-- slot
					end
				s := (slots @ i).twin
				s.left_adjust
				s.right_adjust
				Result.replace_substring (s, pos, pos)
				i := i + 1
			end
		ensure
			Result_exists: Result /= Void
			Result_not_empty: not Result.is_empty
			no_unfilled_slots: slot_count (Result) = 0
		end

invariant

	error_constraint: error_code > 0 implies has_error
	slot_constraint:  error_code > 0 implies
			(slots /= Void and then is_complete (error_code, slots))
	error_code_positive: error_code >= 0
	non_empty_description: has_error implies (error_description /= Void and
			not error_description.is_empty)

end

--|--------------------------------------------------------
--| This file is Copyright (C) 2003 by ETH Zurich.
--|
--| For questions, comments, additions or suggestions on
--| how to improve this package, please write to:
--|
--|     Patrick Schoenbach <pschoenb@gmx.de>
--|		Michela Pedroni <pedronim@inf.ethz.ch>
--|
--|--------------------------------------------------------
