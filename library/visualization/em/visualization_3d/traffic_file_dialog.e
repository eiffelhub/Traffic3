indexing
	description: "Objects that ..."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	TRAFFIC_FILE_DIALOG

inherit

	EM_FILE_DIALOG
		redefine
			make,
			set_directory
		end

create
	make

feature -- Initialization

	make is
			-- Initialize the file dialog with a filter field and default filter for all files.
			-- Redefined because scrolling was problematic if scrollbars were used.
		local
			lbl: EM_LABEL
			s: STRING
		do
			make_from_title ("Select file")
			set_dimension (400, 350)
			set_position ((Video_subsystem.video_surface_width-width)//2, (Video_subsystem.video_surface_height-height)//2)

			create current_directory_label.make_empty
			current_directory_label.set_position (2, 20)
			current_directory_label.set_dimension (396, 20)
			add_widget (current_directory_label)

			create directorylist.make_empty
			directorylist.selection_changed_event.subscribe (agent handle_directory_selected)

			create directory_scrollpanel.make_from_widget (directorylist)
			directory_scrollpanel.set_dimension (198, 210)
			directory_scrollpanel.set_position (2, 40)
			add_widget (directory_scrollpanel)

			create filelist.make_empty
			filelist.selection_changed_event.subscribe (agent handle_file_selected)

			create file_scrollpanel.make_from_widget (filelist)
			file_scrollpanel.set_dimension (198, 210)
			file_scrollpanel.set_position (200, 40)
			add_widget (file_scrollpanel)

			create lbl.make_from_text ("File name:")
			lbl.set_position (5, 250)
			add_widget (lbl)

			create filebox.make_empty
			filebox.set_position (86, 250)
			filebox.set_dimension (width-90, 20)
			add_widget (filebox)

			create lbl.make_from_text ("Files of type:")
			lbl.set_position (5, 272)
			add_widget (lbl)

			create filterbox.make_empty
			filterbox.set_position (86, 272)
			filterbox.set_dimension (filebox.width, 20)
			filterbox.selection_changed_event.subscribe (agent filter_changed)
			add_widget (filterbox)

			create ok_button.make_from_text ("OK")
			ok_button.set_position (width - 10 - 80, height - 25)
			ok_button.set_dimension (80, 20)
			ok_button.clicked_event.subscribe (agent handle_ok_clicked)
			add_widget (ok_button)

			create cancel_button.make_from_text ("Cancel")
			cancel_button.set_position (width - 10 - 80 - 5 - 80, height - 25)
			cancel_button.set_dimension (80, 20)
			cancel_button.clicked_event.subscribe (agent handle_cancel_clicked)
			add_widget (cancel_button)

			close_button_clicked_event.subscribe (agent handle_cancel_clicked)

			-- Add the default filter: *
			create filters.make (5)
			s := "All files (*.*)"
			filters.extend (s, "")
			filterbox.put (s)
			filterbox.set_selected_element (s)

			set_directory (File_system.current_working_directory)

			create button_clicked_event

			-- Dirty hack to change the visuals of the file dialog (should be done in the future with themes)
			title_label.set_background (create {EM_HORIZONTAL_GRADIENT_BACKGROUND}.make_from_colors (create {EM_COLOR}.make_with_rgb (38, 52, 112), create {EM_COLOR}.make_with_rgb (168, 201, 234)))

		end

feature -- Element change

	add_file_filter (a_caption: STRING; a_extension: STRING) is
			-- Add a file filter that filters file with the extension `a_extension' (e.g. "png").
		require
			caption_valid: a_caption /= Void and then not a_caption.is_empty
			extension_valid: a_extension /= Void and then not a_extension.is_empty
		do
			filters.extend (a_extension, a_caption)
			filterbox.put (a_caption)
			filterbox.set_selected_element (a_caption)
		ensure
			filters_has_new_filter: filters.has (a_caption)
		end

	set_directory (a_directory_name: STRING) is
			-- Set `current_directory' to `a_directory_name' and update the displayed files and subdirectories.
			-- Redefined to include support for file filters.
		local
			filter: STRING
			a_directory: KL_DIRECTORY
			directories: ARRAY [STRING]
			files: ARRAY [STRING]
			i: INTEGER
			s: STRING
		do
			if filterbox.has_selected_element then
				filter := filters.item (filterbox.selected_element)
			end
			if File_system.directory_exists (a_directory_name) then
				current_directory := File_system.canonical_pathname (a_directory_name)
			else
				current_directory := File_system.canonical_pathname (File_system.current_working_directory)
			end

			current_directory_label.set_text (current_directory)

			directorylist.wipe_out
			if not File_system.is_root_directory (current_directory) then
				directorylist.put ("..")
			end

			create a_directory.make (current_directory)
			directories := a_directory.directory_names
			if directories /= Void then
				from i := directories.lower until i > directories.upper loop
					directorylist.put (directories.item (i))
					i := i + 1
				end
			end
			directorylist.sort (string_sorter)
			directorylist.resize_to_optimal_dimension
			-- Fixed bug (when the previous directorylist needed scrollbars and the value was not 0,
			-- then the updated directorylist would not display correctly)
			directory_scrollpanel.horizontal_scroll_bar.set_current_value (0)
			directory_scrollpanel.vertical_scroll_bar.set_current_value (0)


			filelist.wipe_out
			if filter = Void or else filter.is_empty then
				files := a_directory.filenames
				if files /= Void then
					from i := files.lower until i > files.upper loop
						filelist.put (files.item (i))
						i := i + 1
					end
				end
			else
				files := a_directory.filenames
				from
					i := files.lower
				until
					i > files.upper
				loop
					s := files.item (i)
					if s.substring (s.count-filter.count+1, s.count).is_equal (filter) then
						filelist.put (s)
					end
					i := i + 1
				end
			end
			filelist.sort (string_sorter)
			filelist.resize_to_optimal_dimension
			-- Fixed bug (when the previous filelist needed scrollbars and the value was not 0,
			-- then the updated filelist would not display correctly)
			file_scrollpanel.horizontal_scroll_bar.set_current_value (0)
			file_scrollpanel.vertical_scroll_bar.set_current_value (0)
		end

feature {NONE} -- Implementation

	directory_scrollpanel: EM_SCROLLPANEL
			-- Scrollpanel for the directorylist

	file_scrollpanel: EM_SCROLLPANEL
			-- Scrollpanel for the filelist

	filterbox: EM_COMBOBOX [STRING]
			-- Textlist for displaying filter functions

	filters: HASH_TABLE [STRING, STRING]
			-- Filters that can be chosen from

	filter_changed (a_string: STRING) is
			-- Update the displayed files according to the selected filter.
		do
			set_directory (current_directory)
		end

end
