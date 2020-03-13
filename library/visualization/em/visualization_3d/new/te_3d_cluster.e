indexing
	description: "Objects that ..."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	TE_3D_CLUSTER inherit

		TE_3D_SHARED_GLOBALS

	create
		make, make_with_default_material

feature -- Initialize

	make(a_material: TE_MATERIAL) is
			-- create the cluster
		do
			create faces.make
			material := a_material
		end

	make_with_default_material is
			-- creates the cluster with a reference to the default material
		do
			create faces.make
			material := default_material
		end



feature -- Access

	faces: LINKED_LIST[INTEGER]

	material: TE_MATERIAL

feature -- Measurement

feature -- Status report

feature -- Status setting

feature -- Cursor movement

feature -- Element change

	set_faces(some_faces: LINKED_LIST[INTEGER]) is
			-- sets the face_list
		do
			faces := some_faces
		end

	set_material(a_material: TE_MATERIAL) is
			-- sets the material
		do
			material := a_material
		end

	clear_faces is
			-- sets the face_list to an empty list
		local
			new_faces: LINKED_LIST[INTEGER]
		do
			create new_faces.make
			faces := new_faces
		end

	push_index (a_index: INTEGER) is
			-- pushes a face_index at the end of the face_list
		do
			faces.extend(a_index)
		end



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

invariant
	invariant_clause: True -- Your invariant here

end
