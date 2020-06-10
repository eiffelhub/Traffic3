note
	description: "Traffic console for output in examples"
	date: "$Date$"
	revision: "$Revision$"

class
	TRAFFIC_CONSOLE

inherit

	EV_TEXT
		rename
			show as display
		export
			{ANY} append_text, prepend_text, remove_text
		end

create
	make_with_text,
	default_create

feature -- Text changes

	show (an_object: ANY) 
			-- Display information on `an_object'.
		require
			an_object_exists: an_object /= Void
		do
			append_text ("%N" + an_object.out)
		end

end
