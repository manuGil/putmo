CREATE OR REPLACE FUNCTION pedestrians.mo_boxRaster(obb geometry, pix_z double precision, srid int)
RETURNS raster AS

$body$
DECLARE

scalx double precision :=pix_z;
scaly double precision :=pix_z;
box geometry;
_srid int;
result raster;

--easting and northing to snap grid:
ULX double precision;
ULY double precision;



BEGIN
_srid:= srid;
 -- SRS origins. Here a small list, it can be extended by finding origin values int the srs_ref_table:

	IF _srid =28992 THEN -- for RD NEW
		ULX:=155000;
		ULY:=463000;
	
		
	ELSIF _srid =31974 THEN -- for SIRGA 2000
		ULX:=500000;
		ULY:=0;
		
	ELSIF _srid =31974 THEN -- for Plate Carre
		ULX:=0;
		ULY:=0;
	
	ELSE 
		RETURN 'No SRS Match definiton, USE: RD_New, SIRGAS_200 or Plate Carre EPSG';
	END IF;
		

box:= obb;
result:= (st_asraster(box, scalx::double precision, scaly::double precision,ULX, ULY,'64BF'::text,1,0)); --1 is the starting value, and 0 as no data.


RETURN result;


END;
$body$
LANGUAGE plpgsql IMMUTABLE STRICT
COST 100;