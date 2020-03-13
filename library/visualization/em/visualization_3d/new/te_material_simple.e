indexing
	description: "Objects that ..."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	TE_MATERIAL_SIMPLE inherit

		TE_MATERIAL
		redefine
			make
		end

		EM_GL_CONSTANTS export {NONE} all end

		GL_FUNCTIONS export {NONE} all end

	create
		make, make_with_color

feature -- Initialization

	make is
			-- creates material with default values
		local
			single_material_pass: EM_EVENT_CHANNEL[TUPLE[]]
		do
			Precursor
			create color.make_xyzt(1.0,1.0,1.0,1.0)
			shaded := true

			-- create material_pass event and subscribe specify to it
			create single_material_pass
			single_material_pass.subscribe (agent specify)
			specify_material_pass.extend(single_material_pass)
		end

	make_with_color(r,g,b: REAL) is
			-- creates material and sets color to specified values
		do
			make
			color.set_xyz (r,g,b)
		end



feature -- Access

	color: GL_VECTOR_4D[REAL]

	shaded: BOOLEAN

feature -- Measurement

feature -- Status report

feature -- Status setting

	enable_shading is
			-- enables shading
		do
			shaded := true
		end

	disable_shading is
			-- disables shading
		do
			shaded := false
		end

	set_color(r,g,b: DOUBLE) is
			-- sets the color
		do
			color.set_xyzt(r,g,b,1.0)
		end


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

	material_in_gl_use: BOOLEAN
			-- is the material currently specified and needs to be removed after use?

	specify is
			-- specifies the material
		do
			material_in_gl_use := true

			gl_push_attrib(em_gl_lighting_bit) -- speichere entsprechende gl zustände
			--enable lighting
			if not shaded then
				gl_disable(em_gl_lighting)
			end
			gl_materialfv(em_gl_front_and_back, em_gl_diffuse, color.pointer)
		end


	remove is
			-- removes the material -- should be called before specifying another material
		require else
			material_currently_used: material_in_gl_use
		do
			gl_pop_attrib -- stell gl zustände wieder her
			material_in_gl_use := false
		end


invariant
	invariant_clause: True -- Your invariant here

end
