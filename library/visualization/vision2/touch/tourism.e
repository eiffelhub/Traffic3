note
	description: "[
					Contains all the predefines and classes to run 'explore'.
					]"
	date: "2005/08/25"
	revision: "1.0"

deferred class
	TOURISM

inherit

	TOUCH_PARIS_OBJECTS

feature -- Access

	run (a_console: TRAFFIC_CONSOLE; a_main_window: TRAFFIC_MAIN_WINDOW)  
			-- Run the example code defined in `explore'.
		require
			a_console_exists: a_console /= Void
		local
			l: TRAFFIC_SIMPLE_LINE -- (Added to ensure compilation of TRAFFIC_SIMPLE_LINE)
			s: TRAFFIC_SIMPLE_STOP  -- (Added to ensure compilation of TRAFFIC_SIMPLE_STOP)
		do
			console := a_console
			main_window := a_main_window
			explore_at_startup
		end

feature  -- Example main feature

	explore_at_startup
			-- Executed on startup.
		do
		end

feature -- Access

	Console: TRAFFIC_CONSOLE
			-- Console for output

feature -- Status report

	is_zurich_loaded: BOOLEAN
			-- Is Zurich loaded?

feature -- Access (Paris)

	Paris: TRAFFIC_CITY
			-- Object representing the city of Paris
		local
			loader: TRAFFIC_MAP_LOADER
			s: STRING
			fs: KL_FILE_SYSTEM
		once
			fs := (create {KL_SHARED_FILE_SYSTEM}).file_system
			s := fs.pathname ("..", "map")
			s := fs.pathname (s, "paris.xml")
			create loader.make (s)
			if not loader.has_error then
				loader.disable_dump_loading
				loader.load_map
				if not loader.has_error then
					Result := loader.city
					main_window.canvas.set_city (loader.city)
					if Result /= Void and then Result.time.is_time_running then
						Result.time.reset
					end
					main_window.resize_canvas
					Result.time.set_speedup (50)
					Result.time.start
					is_paris_loaded := True
					is_zurich_loaded := False
					main_window.move_to_center
					main_window.canvas.redraw_now
				end
			end
		end

	Zurich: TRAFFIC_CITY
			-- Object representing the city of Zurich
		local
			loader: TRAFFIC_MAP_LOADER
			s: STRING
			fs: KL_FILE_SYSTEM
		once
			fs := (create {KL_SHARED_FILE_SYSTEM}).file_system
			s := fs.pathname ("..", "map")
			s := fs.pathname (s, "zurich_big.xml")
			create loader.make (s)
			if not loader.has_error then
				loader.enable_dump_loading
				loader.load_map
				if not loader.has_error then
					Result := loader.city
					main_window.canvas.set_city (loader.city)
					if Result /= Void and then Result.time.is_time_running then
						Result.time.reset
					end
					main_window.resize_canvas
					Result.time.set_speedup (50)
					Result.time.start
					main_window.move_to_center
					main_window.canvas.redraw
					is_paris_loaded := False
					is_zurich_loaded := True
				end
			end
		end

feature -- Basic operations

	show_spot (a_location: TRAFFIC_POINT)
			-- Show a yellow small spot at `a_location' for `Wait_time' seconds.
		local
			s: DRAWABLE_SPOT
		do
			create s.make (create {REAL_COORDINATE}.make (a_location.x, -a_location.y))
			s.set_color (create {EV_COLOR}.make_with_8_bit_rgb (255, 255, 0))
			s.enable_filled
			s.set_diameter (10)
			main_window.canvas.object_list.put_last (s)
			wait
			main_window.canvas.object_list.delete (s)
		end

	show_big_red_spot (a_location: TRAFFIC_POINT)
			--  Show a red big spot at `a_location' for `Wait_time' seconds.
		local
			s: DRAWABLE_SPOT
		do
			create s.make (create {REAL_COORDINATE}.make (a_location.x, -a_location.y))
			s.set_color (create {EV_COLOR}.make_with_8_bit_rgb (255, 0, 0))
			s.enable_filled
			s.set_diameter (20)
			main_window.canvas.object_list.put_last (s)
			wait
			main_window.canvas.object_list.delete (s)
		end

	show_blinking_spot (a_location: TRAFFIC_POINT)
			--  Show blinking green spot
		local
			s: DRAWABLE_SPOT
		do
		create s.make (create {REAL_COORDINATE}.make (a_location.x, -a_location.y))
			s.set_color (create {EV_COLOR}.make_with_8_bit_rgb (0, 255, 0))
			s.enable_filled
			s.set_diameter (10)

			main_window.canvas.object_list.put_last (s)
			short_wait
			main_window.canvas.object_list.delete (s)
			short_wait
			main_window.canvas.object_list.put_last (s)
			short_wait
			main_window.canvas.object_list.delete (s)
			wait
		end

	show_green_spot (a_location: TRAFFIC_POINT)
			-- Show a green medium spot at `a_location' for `Wait_time' seconds.
		local
			s: DRAWABLE_SPOT
		do
			create s.make (create {REAL_COORDINATE}.make (a_location.x, -a_location.y))
			s.set_color (create {EV_COLOR}.make_with_8_bit_rgb (0, 255, 0))
			s.enable_filled
			s.set_diameter (15)
			main_window.canvas.object_list.put_last (s)
			wait
			main_window.canvas.object_list.delete (s)
		end


feature {NONE} -- Implementation

	main_window: TRAFFIC_MAIN_WINDOW

end
