-- Function: pedestrians.uncertainty_seg(geometry, geometry, timestamp with time zone, timestamp with time zone, double precision, double precision, real, double precision)

-- DROP FUNCTION pedestrians.uncertainty_seg(geometry, geometry, timestamp with time zone, timestamp with time zone, double precision, double precision, real, double precision);

CREATE OR REPLACE FUNCTION pedestrians.uncertainty_seg(start_point geometry, end_point geometry, t_start timestamp with time zone, t_end timestamp with time zone, pix_z double precision, sigma double precision, s_ratio real, srid int)
  RETURNS raster AS
$BODY$

<<main>>
/*Compute the uncertianty along a line segment, given the endpoints, timestamps and error: sigma.
scale: pixel size
s_ratio, determine, s_max (the sigma maxima) half way between 2 consecutive time stamps; units are 
given in percentage sigma over time in seconds, and it goes from cero (0) to infinity, when cero sigma does not change
along a trajectory segment*/
 

DECLARE


obb geometry;
output_ras raster;
s_max double precision; -- sigma maxima at the middle of the line segment
sigma double precision:= sigma; --sigma as given in function parameters
sig double precision; --sigma in the further computations, moving sigma
_confidence double precision;
pixel_val double precision;
scalx double precision:=pix_z;
scaly double precision:=pix_z;

--to fill in raster:
width smallint;
height smallint;

i smallint;
j smallint;

--SUPPORT to compute uncertainty value:
ULX double precision;
ULY double precision;
ULPD double precision;
LLPD double precision;
LRPD double precision;
URPD double precision;
MPPD double precision;


q geometry; --a pixel centroid

q_line geometry; -- q projected on the line (using closest projection)

qlx double precision; --moving x-mean
qly double precision; --moving y-mean
dist_qline double precision; --distance from q on the line to start point
l_leng double precision; --length of the line segment


			
pixel_init double precision;

--geometry constructors:
_srid int; 
l_seg geometry; -- line segment

--for parabola computation:

a double precision; -- for smoothing ellipse error

--checkers:



BEGIN

_srid:= srid;
----------------------------------------------------
--  COMPUTE CHANGE IN sigma using linear relation --
----------------------------------------------------

IF st_equals(start_point,end_point) = false THEN


s_max:= mo_sigMax(sigma, s_ratio, t_start, t_end);


--Create geometry box around line segment:
obb:= pedestrians.mo_obb(start_point, end_point, s_max)::geometry;

--Convert geometry box to raster (empty raster):


output_ras:=pedestrians.mo_boxRaster(obb, scalx,_srid);

--find width & height of the empty raster:
width:= st_width(output_ras);
height:= st_height(output_ras);




--construct line segment:

l_seg:= st_setSRID(st_makeLine(start_point,end_point),_srid);
l_leng:= st_length(l_seg);

BEGIN
-- COMPUTE a, constant that defines parabola (behaviour) of sigma along the line segment
-- Constant for line segment

a:= 2*(s_max - sigma) / (l_leng*l_leng);


END;


FOR i in 1..width
	LOOP
		FOR j IN 1..height
		LOOP
			IF st_value(output_ras,i,j)=1.0
			THEN 


			--centroid  of the pixel 'q'
			ULX:= ST_Raster2WorldCoordX(output_ras,i,j) + scalx/2;	--This function returns the x-coordinates of upperleft corner 
			ULY:= ST_Raster2WorldCoordy(output_ras,i,j) - scaly/2;


			

			--q:= st_geomfromtext(q_wkt,srid); --point over centroid of upper-left corner of pixel
			q:= st_setsrid(st_MakePoint(ULX, ULY),_srid);
			q_line:= st_closestPoint(l_seg, q); --project q to the closest point on the line segment

			-- coordinates of q' on the line = moving means:

			qlx:= st_x(q_line);
			qly:= st_y(q_line);

			
			--distance start_point to q_line
			dist_qline:= st_distance(start_point,q_line);
			

			
			IF st_equals(start_point,q_line) = true OR st_equals(end_point,q_line)=true THEN
				sig:= sigma;
				
			ELSE 
			
				--Compute new sigma based on the position along line segment:
				sig:= sigma + a*(dist_qline)*(l_leng - dist_qline);
	
			
			END IF;


			--calculate probability density at each corner and middle point of each cells
			
			--For upperleft
			ULPD:= pedestrians.mo_probability_density(ULX,ULY,qlx,qly,sig); 
			IF ULPD <> 0.0 THEN
				-- For lowerleft
				LLPD:= pedestrians.mo_probability_density(ULX,ULY-scalx,qlx,qly,sig);

				IF LLPD <> 0.0 THEN
				
					--For lowerright
					LRPD:= pedestrians.mo_probability_density(ULX+scalx,ULY-scalx,qlx,qly,sig);
				 
					IF LRPD <> 0.0 THEN
				
						--For upperright
						URPD:= pedestrians.mo_probability_density(ULX+scalx,ULY,qlx,qly,sig); 
			
			
						IF URPD <> 0.0 THEN
				
							--For middle point 
							MPPD:= pedestrians.mo_probability_density(ULX+(scalx/2.0),ULY-(scalx/2.0),qlx,qly,sig); 
							IF MPPD <> 0.0 THEN
			
							--Now calculating volume under each triangles of pyramid and summing up them, 
							--the formula used below is after simplification, given by Deepak.

		
							BEGIN
							pixel_val:=1/6.0 *(scalx*scalx)*(ULPD+LLPD+2*MPPD+LRPD+URPD)::double precision;
			
							EXCEPTION 
								WHEN numeric_value_out_of_range THEN
								pixel_val:=0.00000;
							RETURN pixel_val::double precision;
							END;
							END IF;
						--ELSE
						--pixel_val:=0.00000;
						END IF;
					--ELSE
					--pixel_val:=0.00000;
					END IF;
				--ELSE
				--pixel_val:=0.00000;
				END IF;

			ELSE
			pixel_val:=0.00000;
			END IF;

			/*EXCEPTION
				WHEN numeric_value_out_of_range OR division_by_zero THEN
				pixel_val:=0.00000;
			RETURN pixel_val::double precision;
			END;
			*/


		--	BEGIN
			
		output_ras := st_SetValue(output_ras,i,j,pixel_val);

			/*
			EXCEPTION
			WHEN internal_error THEN
			RAISE NOTICE 'ERROR AT SETTING PIX VALUE';
			output_ras:= st_setValue(output_ras,i,j,0.0);
			END;
			
*/
	
			
			END IF;

		END LOOP;

	END LOOP;
	
END IF;

RETURN output_ras;




END;
$BODY$
  LANGUAGE plpgsql IMMUTABLE
  COST 1000;

