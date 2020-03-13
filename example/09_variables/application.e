note
	description	: "Root class for this application."
	author		: "Corinne Mueller."
	date		: "10.01.2008"
	revision	: "1.0.0"

class
	APPLICATION

inherit
	EV_APPLICATION

create
	make_and_launch

feature {NONE} -- Initialization

	make_and_launch
			-- Initialize and launch application
		do
			default_create
			prepare
			launch
		end

	prepare 
			-- Prepare the first window to be displayed.
		local
			assi: ASSIGNMENTS
		do
			create first_window
			create assi
			first_window.set_example (assi, agent assi.startup)
			first_window.set_title ("Variables, Assignment and References (Chapter 9, Touch of Class)")
			first_window.show
		end

feature {NONE} -- Implementation

	first_window: TRAFFIC_MAIN_WINDOW
			-- Main window.

end -- class APPLICATION
