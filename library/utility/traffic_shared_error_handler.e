indexing

	description: "[

		Shared error message handler

	]"
	date: "$Date$"
	revision: "$Revision$"

class TRAFFIC_SHARED_ERROR_HANDLER

feature -- Access

	Error_handler: TRAFFIC_ERROR_HANDLER is
			-- EiffelMedia error handler
		once
			create Result.make
		ensure
			error_handler_not_void: Result /= Void
		end

end
