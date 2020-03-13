indexing
	description: "A tokenzier suited for iterative scanning."
	date: "$Date: 2005/06/21 15:16:28 $"
	revision: "$Revision: 1.4 $"

class
	TE_3D_TEXT_SCANNER

create
	make_from_string_with_delimiters

feature {NONE} -- Initialization

	make_from_string_with_delimiters (a_string: STRING; the_delimiters: STRING) is
			-- Initialize with `a_string' as source and `the_delimiters' as delimiters.
		require
			a_string_exists: a_string /= Void
			delimiters_exists: the_delimiters /= Void
		do
			source := a_string
			delimiters := the_delimiters
			start_idx := next_start (1)
			create last_string.make_empty
		ensure
			source_set: source = a_string
			delimiters_set: delimiters = the_delimiters
			last_string_exists: last_string /= Void
		end

feature -- Basic operations

	set_source_string (a_string: STRING) is
			-- Set `source' to `a_string'.
		require
			a_string_exists: a_string /= Void
		do
			source := a_string
			start_idx := next_start (1)
		ensure
			source_set: source = a_string
		end

	read_token is
			-- Read next token and make it available through `last_string'.
		local
			finish_idx: INTEGER
		do
			finish_idx := next_finish (start_idx)
			last_string.set (source, start_idx, finish_idx)
			start_idx := next_start (finish_idx + 1)
		ensure
			last_string_exists: last_string /= Void
		end

feature -- Access

	last_string: STRING
			-- Last token read

feature {NONE} -- Implementation
	next_start (start_ix: INTEGER): INTEGER is
			-- Start of next token starting search at `start_ix'
		require
			start_ix_valid: start_ix > 0
		do
			from
				Result := start_ix
			until
				(Result > source.count) or else not (delimiters.has (source @ Result))
			loop
				Result := Result + 1
			end
		end

	next_finish (start_ix: INTEGER): INTEGER is
			-- End of next token starting search at `start_ix'
		require
			start_ix_valid: start_ix > 0
		do
			from
				Result := start_ix
			until
				(Result > source.count) or else delimiters.has (source @ Result)
			loop
				Result := Result + 1
			end
			Result := Result - 1
		end

	find_next_delim (start: INTEGER): INTEGER is
			-- Position of next delimiter starting search at `start'
		require
			start_valid: start > 0
		local
			curr_delim: INTEGER
			curr_index: INTEGER
		do
			from
				curr_delim := 1
				Result := source.count
			until
				curr_delim > delimiters.count
			loop
				curr_index := source.index_of (delimiters.item (curr_delim), start)
				if curr_index > 0 and curr_index < Result then
					Result := curr_index
				end
				curr_delim := curr_delim + 1
			end
			if Result = source.count then
				Result := 0
			end
		end

	source: STRING
			-- Source to search

	delimiters: STRING
			-- Delimiters identifying tokens

	start_idx: INTEGER
			-- Current index

invariant

	source_exists: source /= Void

end
