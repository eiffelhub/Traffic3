note
	description: "XML processors for <building> nodes."
	date: "$Date:$"
	revision: "$Revision:$"

class
	TRAFFIC_BUILDING_NODE_PROCESSOR

obsolete "Needs reworking"

inherit
	TRAFFIC_NODE_PROCESSOR

	MATH_CONST
			export{NONE} all end

create
	make


feature -- Access

	Name: STRING = "building"
			-- Name of element to process

	Mandatory_attributes: ARRAY [STRING]
			-- Table of mandatory attributes
		do
			Result := << "name", "x1", "x2", "y1", "y2", "height", "angle" >>
			Result.compare_objects
		end

feature -- Basic operations

	process 
			-- Process node.
		local
			building: TRAFFIC_BUILDING

			x1,x2: REAL_64
			y1,y2: REAL_64
			height: REAL_64
			angle: REAL_64
			building_name: STRING
			p1,p2,p3,p4: TRAFFIC_POINT
			center: TRAFFIC_POINT
		do
			-- Check whether aributes exist and have proper type
			if not has_attribute ("name") then
				set_error (Mandatory_attribute_missing, << "name" >>)
			elseif not has_attribute ("x1") then
				set_error (Mandatory_attribute_missing, << "x1" >>)
			elseif not has_attribute("x2") then
				set_error (Mandatory_attribute_missing, << "x2" >>)
			elseif not has_attribute ("y1") then
				set_error (Mandatory_attribute_missing, << "y1" >>)
			elseif not has_attribute ("y2") then
				set_error (Mandatory_attribute_missing, << "y2" >>)
			elseif not (is_attribute_integer ("x1") and is_attribute_integer ("x2") and
						(is_attribute_integer ("y1") and is_attribute_integer ("y2")) or
						(is_attribute_double ("x1") and is_attribute_double ("x2")) and
						is_attribute_double ("y1") and is_attribute_double ("y2")) then
				set_error (Wrong_attribute_type, << "x", "y" >>)
			elseif not has_attribute ("height") then
				set_error (Mandatory_attribute_missing, << "height" >>)
			elseif not has_attribute ("angle") then
				set_error (Mandatory_attribute_missing, << "angle" >>)
			elseif not (is_attribute_integer("height") and is_attribute_double("height")) then
				set_error (Wrong_attribute_type, << "height" >>)
			elseif not (is_attribute_integer("angle") and is_attribute_double("angle"))  then
				set_error (Wrong_attribute_type, << "angle" >>)
			else
				--Create new building
				x1 := attribute_double("x1")
				x2 := attribute_double("x2")
				y1 := attribute_double("y1")
				y2 := attribute_double("y2")
				height := attribute_double("height")
				angle := attribute_double ("angle")
				if angle > 70 or angle < -70 then
					io.putstring ("Angle has to be in range -70 to 70 degrees")
					angle := 0
				end
				building_name := xml_attribute ("name")
				create p1.make(x1,y1)
				create p2.make(x1,y2)
				create p3.make(x2,y2)
				create p4.make(x2,y1)
				create center.make ((x1+x2)/2,(y1+y2)/2)
				p1 := p1.rotation (center, -angle*pi/180)
				p2 := p2.rotation (center, -angle*pi/180)
				p3 := p3.rotation (center, -angle*pi/180)
				p4 := p4.rotation (center, -angle*pi/180)
--				create building.make (p1,p2,p3,p4, height, building_name)

				building.set_angle (angle)
				city.buildings.put_last (building)
			end
		end
end
