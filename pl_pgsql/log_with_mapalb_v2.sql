CREATE OR REPLACE FUNCTION pedestrians.mo_Log(to_schema text, new_table text, input_ras raster) RETURNS text AS
$$

DECLARE


_to_schema text;


_rast_table text;
result raster;

_new_table text;

 in_raster raster;


expression text;

BEGIN



_to_schema:= to_schema;


expression:= '1/(-1*log([rast]))';
_new_table := new_table;

in_raster:= input_ras;

--Prepare the new table
EXECUTE format ('CREATE TABLE  IF NOT EXISTS %I.%I (rid serial PRIMARY KEY, rast raster, rast_id varchar)', _to_schema, _new_table);

EXECUTE format ('UPDATE %I.%I SET rast=st_setsrid(rast,28992)',_to_schema, _new_table);


	result:= ST_MapAlgebraExpr(in_raster::raster,1,NULL,expression); 



EXECUTE format ('INSERT INTO %I.%I (rast) VALUES (%L::raster)', _to_schema, _new_table, result);

RETURN  'Raster was inserted successfully';

END;
$$
LANGUAGE plpgsql VOLATILE
COST 100;

