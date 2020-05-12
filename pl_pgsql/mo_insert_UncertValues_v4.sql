

CREATE OR REPLACE FUNCTION pedestrians.mo_insert_UncertValues(st_p int, end_p int, pixel_z double precision, sigma double precision, sig_ratio real, srid int)
RETURNS void AS
$$

-- r_table: name of an exsiting table where the values are going to be inseted.
-- g_table: name of the table that containts the points.
-- po adn p1  refer to the id of two consecutive points.


DECLARE

po geometry;
p1 geometry;

t_o timestamp with time zone;
t_1 timestamp with time zone;

_srid int;



BEGIN

_srid:=srid;

t_o:= (SELECT p.time_ FROM "temp1" AS p WHERE p.new_id2=st_p);
t_1:= (SELECT p.time_ FROM "temp1"  AS p WHERE p.new_id2=end_p);


po:= (SELECT p.the_geom FROM "temp1" AS p WHERE p.new_id2=st_p);
p1:= (SELECT p.the_geom FROM "temp1"  AS p WHERE p.new_id2=end_p);




BEGIN
INSERT INTO  "rast_temp"
	("rast") VALUES (pedestrians.Uncertainty_Seg(
		 po, --start point
		 p1, --end point
		 t_o, --start time
		 t_1, --end time
		 pixel_z, --pixel size
		sigma, -- standard deviation
		sig_ratio, -- S/time change in percentage
		_srid )::raster);  
		
EXCEPTION WHEN internal_error THEN
	RAISE NOTICE 'error at INSERTING VALUE TO TABLE, AT SEGMENT: % to %', st_p, end_p;

END;

END;
$$
LANGUAGE plpgsql VOLATILE
COST 200;
