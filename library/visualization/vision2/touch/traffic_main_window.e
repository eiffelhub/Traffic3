note
	description: "Vision2 Main window for touch examples, containing a console and a button plus a city canvas"
	date: "$Date$"
	revision: "$Revision$"

class
	TRAFFIC_MAIN_WINDOW

inherit
	EV_TITLED_WINDOW
		redefine
			initialize
		end

	KL_SHARED_FILE_SYSTEM
		undefine
			default_create,
			copy
		end

create
	default_create

feature {NONE} -- Initialization

	initialize
			-- Build the interface for this window.
		do
			Precursor {EV_TITLED_WINDOW}
				-- Create and add the status bar.
			build_standard_toolbar
			upper_bar.extend (create {EV_HORIZONTAL_SEPARATOR})
			upper_bar.extend (standard_toolbar)
			build_standard_status_bar
			lower_bar.extend (standard_status_bar)
			build_main_container
			extend (main_container)
				-- Execute `request_close_window' when the user clicks
				-- on the cross in the title bar.
			close_request_actions.extend (agent request_close_window)
				-- Set the title of the window
			set_title (Window_title)
				-- Set the initial size of the window
			set_size ((canvas.width*1.2).floor, (canvas.height*1.2).floor)
		end

feature -- Basic operations

	set_example (a_example: TOURISM; an_action: PROCEDURE [ANY, TUPLE])
			-- Set `a_example' to be run when clicking on the `run_button'.
		do
			a_example.run (console, Current)
			run_button.select_actions.extend (an_action)
		end

feature {NONE} -- GUI building

	build_main_container
			-- Create and populate `main_container'.
		require
			main_container_not_yet_created: main_container = Void
		local
			hb1: EV_HORIZONTAL_BOX
			fr: EV_FRAME
			fixed: EV_FIXED
		do
			create viewport
			viewport.set_offset (0, 0)
			create hb1
			create fr
			create canvas.make
			create main_container
			create fixed

			viewport.set_minimum_height (600)
			viewport.set_minimum_width (600)
			viewport.extend (canvas)
			fr.extend (viewport)
			canvas.set_zoom_limits (0.5, 10.0)
			viewport.resize_actions.force_extend (agent resize_canvas)

			-- Example button
			create run_button.make_with_text ("Run example")
			fixed.extend (run_button)
			fixed.set_item_position (run_button, 5, 2)

			create console.default_create
			console.set_minimum_size (200, 400)
			console.disable_edit
			fixed.extend (console)
			fixed.set_item_position (console, 5, 35)

			hb1.extend (fixed)
			hb1.disable_item_expand (fixed)
			hb1.extend (fr)
			main_container.extend (hb1)
			main_container.set_padding (10)
		ensure
			main_container_created: main_container /= Void
		end

	build_standard_status_bar
			-- Create and populate the standard toolbar.
		require
			status_bar_not_yet_created:
				standard_status_bar = Void and then
				standard_status_label = Void
		local
			env: EV_ENVIRONMENT
		do
				-- Create the status bar.
			create standard_status_bar
			standard_status_bar.set_border_width (2)

				-- Populate the status bar.
			create standard_status_label.make_with_text ("Please run the example...")
			standard_status_label.align_text_left
			standard_status_bar.extend (standard_status_label)

			create env
			env.application.add_idle_action (agent update_status_label)
		ensure
			status_bar_created:
				standard_status_bar /= Void and then
				standard_status_label /= Void
		end

	build_standard_toolbar
			-- Create and populate the standard toolbar.
		require
			toolbar_not_yet_created: standard_toolbar = Void
		local
			toolbar_item: EV_TOOL_BAR_BUTTON
			toolbar_pixmap: EV_PIXMAP
		do
			create standard_toolbar
			create toolbar_item
			create toolbar_pixmap
			toolbar_pixmap.set_with_named_file (File_system.absolute_pathname (File_system.pathname_from_file_system ("..\image\zoom_in.png", Windows_file_system)))
			toolbar_item.set_pixmap (toolbar_pixmap)
			toolbar_item.select_actions.extend (agent zoom_in)
			standard_toolbar.extend (toolbar_item)
			create toolbar_item
			create toolbar_pixmap
			toolbar_pixmap.set_with_named_file (File_system.absolute_pathname (File_system.pathname_from_file_system ("..\image\zoom_out.png", Windows_file_system)))
			toolbar_item.set_pixmap (toolbar_pixmap)
			toolbar_item.select_actions.extend (agent zoom_out)
			standard_toolbar.extend (toolbar_item)
		ensure
			toolbar_created: standard_toolbar /= Void and then  not standard_toolbar.is_empty
		end

feature {NONE} -- Implementation

	request_close_window
			-- The user wants to close the window
		local
			question_dialog: EV_CONFIRMATION_DIALOG
		do
			create question_dialog.make_with_text (Label_confirm_close_window)
			question_dialog.show_modal_to_window (Current)

			if question_dialog.selected_button.is_equal ((create {EV_DIALOG_CONSTANTS}).ev_ok) then
					-- Destroy the window
				destroy;

					-- End the application
					--| TODO: Remove this line if you don't want the application
					--|       to end when the first window is closed..
				(create {EV_ENVIRONMENT}).application.destroy
			end
		end

	update_status_label
			--
		do
			if canvas.city /= Void and then canvas.city.time.is_time_running then
				standard_status_label.set_text (canvas.city.time.out)
			end
		end

feature -- Widgets

	standard_toolbar: EV_TOOL_BAR
			-- Standard toolbar for this window

	standard_status_bar: EV_STATUS_BAR
			-- Standard status bar for this window

	standard_status_label: EV_LABEL
			-- Label situated in the standard status bar.
			--
			-- Note: Call `standard_status_label.set_text (...)' to change the text
			--       displayed in the status bar.

	console: TRAFFIC_CONSOLE
			-- Console for output

	run_button: EV_BUTTON
			-- Clicking this button will run example

	main_container: EV_VERTICAL_BOX
			-- Main container (contains all widgets displayed in this window)

	canvas: TRAFFIC_CITY_CANVAS
			-- Canvas widget

	viewport: EV_VIEWPORT
			-- Viewport that contains the canvas

feature -- Basic operations

	resize_canvas
			-- Set up canvas.
		local
			w: INTEGER
			h: INTEGER
		do
			w := (viewport.width).max (1)
			h := (viewport.height).max (1)
			canvas.set_size (w, h)
			canvas.set_minimum_size (w, h)
			viewport.set_item_size (w, h)
		end

	move_to_center
			-- Center city on screen.
		local
			xdiff, ydiff: REAL_64
			canvas_center: REAL_COORDINATE
		do
			canvas_center := client_to_city_coordinates ((canvas.width/2).floor, (canvas.height/2).floor)
			xdiff := canvas.city.center.x - canvas_center.x
			ydiff := (-1)*canvas.city.center.y - canvas_center.y
			if xdiff /= 0 or ydiff /= 0 then
				canvas.go_down (ydiff)
				canvas.go_left (xdiff)
			end
			canvas.redraw
		end

	zoom_in
			-- Zoom in.
		do
			Canvas.zoom_in (Zoom_factor_stepwise)
		end

	zoom_out
			-- Zoom out.
		do
			Canvas.zoom_out (Zoom_factor_stepwise)
		end

feature -- Conversion

	client_to_city_coordinates (x, y: INTEGER): REAL_COORDINATE
			-- City position that corresponds to client coordinates (`x', `y')
		local
			lx: REAL_64
			ly: REAL_64
			xperc: REAL_64
			yperc: REAL_64
			h: INTEGER
			org: REAL_COORDINATE
		do
			lx := x / 1
			ly := y / 1

			xperc := lx / (canvas.parent.client_width)
			h := (canvas.parent.client_height).max (1)
			yperc := (h - ly) / h

			org := canvas.visible_area.lower_left
			create Result.make (
				(org.x + xperc * canvas.visible_area.width).rounded,
				(org.y + yperc * canvas.visible_area.height).rounded)

		ensure
			Result_exists: Result /= Void
		end

feature {NONE} -- Implementation / Constants

	Window_title: STRING = "touch example"
			-- Title of the window.

	Window_width: INTEGER = 800
			-- Initial width for this window.

	Window_height: INTEGER = 600
			-- Initial height for this window.

	Label_confirm_close_window: STRING = "You are about to close this window.%NClick OK to proceed."
			-- String for the confirmation dialog box that appears
			-- when the user try to close the first window.

	Zoom_factor_stepwise: REAL_64 = 0.05
			-- Stepwise zoom factor
end
