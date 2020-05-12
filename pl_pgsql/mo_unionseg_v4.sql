-- Function: pedestrians.mo_unionseg(text, double precision, double precision, real)

-- DROP FUNCTION pedestrians.mo_unionseg(text, double precision, double precision, real);

CREATE OR REPLACE FUNCTION pedestrians.mo_unionseg(from_schema text, to_schema text, data_set text, trip text, srid int, pix_size double precision, sigma double precision, sig_ratio real)
  RETURNS void AS
$BODY$

DECLARE

_data_set text;
trip text:=trip;
table_name text;
return_val text:='MAX';
_from_schema text;
_to_schema text;

_srid int;


BEGIN

_data_set:= data_set;

_from_schema:=from_schema;
_to_schema:= to_schema;
_srid:=srid;


--Compute rasters for each trajectory segment:
PERFORM pedestrians.mo_uncertainty_traj(_from_schema, _data_set,trip,_srid, pix_size, sigma, sig_ratio);

raise notice 'dataset: %', _data_set;

--storage table:
table_name:='rast_'||trip;

-----------------------------------------------------------------
-- UNION OF ALL SEGMENTS AND RETURNING THE MAXIMUM PIXEL VALUE --
-----------------------------------------------------------------


EXECUTE format ('DROP TABLE IF EXISTS %I.%I', _to_schema, table_name); 

EXECUTE format('CREATE TABLE %I.%I (rid serial PRIMARY KEY, rast raster, track_id varchar)', _to_schema, table_name);

EXECUTE format('UPDATE %I.%I SET rast=st_setsrid(rast,$1)', _to_schema, table_name) USING _srid;

EXECUTE format ('INSERT INTO %I.%I (rast, track_id) VALUES ((SELECT St_union (rast, %L) FROM "rast_temp")::raster, $1::varchar)',_to_schema, table_name, return_val)
	USING trip;


EXECUTE format('ANALYZE %I.%I',_to_schema, table_name);

--droping temporal raster table:
DROP TABLE rast_temp;


END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 5000;

