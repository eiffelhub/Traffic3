indexing
	description: "Objects that ..."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	TE_MATERIAL_FACTORY_MTL inherit

		TE_MATERIAL_FACTORY

		EM_SHARED_BITMAP_FACTORY

		KL_SHARED_FILE_SYSTEM

	create
		make

feature -- Access

feature -- Material List Creation

	create_material_list_from_file(a_filename:STRING) is
			-- creates a material list from a mtl file
		require
			must_be_mtl: a_filename.substring (a_filename.count - 2, a_filename.count).is_equal ("mtl")
		do
			clear
			load_mtl_file(a_filename)
		end

feature -- Status report

feature -- Status setting

feature -- Cursor movement

feature -- Element change

feature -- Removal

feature -- Resizing

feature -- Transformation

feature -- Conversion

feature -- Duplication

feature -- Miscellaneous

feature -- Basic operations

feature -- Obsolete

feature -- Inapplicable

feature {NONE} -- Implementation

	load_mtl_file(a_filename:STRING)
			--loads the obj file information
			--IMPORTANT: mtl files must have an empty line at the end of the file!
		require
			must_be_mtl: a_filename.substring (a_filename.count - 2, a_filename.count).is_equal ("mtl")
		local
			mtl_file: PLAIN_TEXT_FILE
			tokenizer: TE_3D_TEXT_SCANNER
			first_definition_set: BOOLEAN
			f: STRING
		do
			from
				create mtl_file.make_open_read (a_filename)
				create tokenizer.make_from_string_with_delimiters ("", " %T")
			until
				mtl_file.after
			loop
				mtl_file.read_line
				if not mtl_file.last_string.is_empty then
					tokenizer.set_source_string (mtl_file.last_string)
					-- set the iterator
					tokenizer.read_token

					if  tokenizer.last_string.is_equal ("newmtl") then
						--new material definition
						if first_definition_set then --if this is not the first material which gets defined
							build_and_push_material -- create material with current material settings and push it to the material list
						end
						tokenizer.read_token
						name := tokenizer.last_string.twin
						first_definition_set := true
					elseif tokenizer.last_string.is_equal ("Ka") then
						-- RGB vector for ambient color
						tokenizer.read_token
						ambient_color := read_RGB (tokenizer)
					elseif tokenizer.last_string.is_equal ("Kd") then
						-- RGB vector for diffuse color
						tokenizer.read_token
						diffuse_color := read_RGB (tokenizer)
					elseif tokenizer.last_string.is_equal ("Ks") then
						-- RGB vector for specular color
						tokenizer.read_token
						specular_color := read_RGB (tokenizer)
					elseif tokenizer.last_string.is_equal ("Ke") then
						-- RGB vector for emissive color
						tokenizer.read_token
						emissive_color := read_RGB (tokenizer)
					elseif tokenizer.last_string.is_equal ("d") or tokenizer.last_string.is_equal ("Tr") then
						-- DOUBLE value for aplha transparency
						tokenizer.read_token
						opacity := tokenizer.last_string.to_double
					elseif tokenizer.last_string.is_equal ("Ns") then
						-- DOUBLE value for specularity
						tokenizer.read_token
						shininess.set_value(tokenizer.last_string.to_double)
					elseif tokenizer.last_string.is_equal ("illum") then
						-- INTEGER - if this is 1, then speculars are not used, if it's 2, then speculars are used
						-- TODO!
					elseif tokenizer.last_string.is_equal ("map_Kd")  then
						-- Texture file to be used
						tokenizer.read_token
						f := file_system.pathname (file_system.dirname (a_filename), tokenizer.last_string)
						bitmap_factory.create_bitmap_from_image (f)--tokenizer.last_string)
						diffuse_texture := bitmap_factory.last_bitmap.texture
					elseif tokenizer.last_string.is_equal ("map_Ke")  then
						-- Texture file to be used
						tokenizer.read_token
						f := file_system.pathname (file_system.dirname (a_filename), tokenizer.last_string)
						bitmap_factory.create_bitmap_from_image (f)--tokenizer.last_string)
						emissive_texture := bitmap_factory.last_bitmap.texture
					elseif tokenizer.last_string.is_equal ("alphat")  then
						-- Texture file to be used
						tokenizer.read_token
						if tokenizer.last_string.to_integer = 1 then
							enable_alpha_testing
						end
					else
						-- ignore this line, since I can't use it
					end
				elseif mtl_file.last_string.is_empty and first_definition_set then
					build_and_push_material --build and push the last material defined in the file
				end
			end
		end

	read_RGB (tokenizer: TE_3D_TEXT_SCANNER): GL_VECTOR_4D[DOUBLE] is
			-- Read the color data from the current position
		local
			i: INTEGER
			double_array: ARRAY[DOUBLE]
		do
			create double_array.make(0,2)

			from
				i := 0
			until
				i > 2
			loop
				double_array.force (tokenizer.last_string.to_double, i)
				tokenizer.read_token
				i := i + 1
			end
			create Result.make_xyzt (double_array.item(0), double_array.item(1), double_array.item(2), 1.0)
		end

invariant
	invariant_clause: True -- Your invariant here

end
