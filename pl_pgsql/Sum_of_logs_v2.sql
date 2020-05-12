CREATE OR REPLACE FUNCTION pedestrians.mo_SumLogs(logs_dataset text, to_schema text)
RETURNS void AS
$$

DECLARE

_logs_dataset text;
output_tbl text;
return_val text:='SUM';
_to_schema text;

BEGIN

_to_schema:= to_schema;
_logs_dataset:= logs_dataset;

--table name to store resutls:
output_tbl:='sum_'||_logs_dataset;


EXECUTE format ('DROP TABLE IF EXISTS  %I.%I', _to_schema, output_tbl); 

EXECUTE format('CREATE TABLE %I.%I (rid serial PRIMARY KEY, rast raster, track_id varchar)', _to_schema, output_tbl);

EXECUTE format('UPDATE %I.%I SET rast=st_setsrid(rast,28992)', _to_schema, output_tbl);

EXECUTE format ('INSERT INTO %I.%I (rast) VALUES ((SELECT St_union (rast, %L) FROM %I)::raster)', _to_schema, output_tbl, return_val,_logs_dataset);

EXECUTE format('ANALYZE %I.%I', _to_schema, output_tbl);


END;
$$
LANGUAGE plpgsql VOLATILE
COST 200;
 

