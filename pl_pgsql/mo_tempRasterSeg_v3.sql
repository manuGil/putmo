
-- drop function pedestrians.mo_selection(trip varchar);

CREATE OR REPLACE FUNCTION pedestrians.mo_tempRasterSeg(srid int)
RETURNS void AS

$$

-- Create a empty table to temporarly store indiviual raster segment. 

DECLARE

_srid int;

BEGIN

_srid:=srid;

CREATE TEMPORARY TABLE "rast_temp"(rid serial PRIMARY KEY, rast raster);
UPDATE "rast_temp" set rast=st_setsrid(rast,_srid::int);

--CREATE INDEX "ind_rast_temp" ON "mo"."rast_temp" USING gist (st_convexhull("rast"));



END;
$$
LANGUAGE plpgsql VOLATILE
COST  100;

