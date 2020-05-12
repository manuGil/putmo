

-- drop function pedestrians.mo_selection(trip varchar);

CREATE OR REPLACE FUNCTION pedestrians.mo_selection(trip varchar, from_schema text, data_set text)
RETURNS void AS

$$
DECLARE

trip_id varchar:=trip;
_data_set text;
_from_schema text;

BEGIN

_data_set:= data_set;
_from_schema:= from_schema;


EXECUTE format('CREATE TEMPORARY TABLE temp1 AS SELECT t.* FROM %I.%I AS t WHERE t.tripid =%L',_from_schema, _data_set, trip_id);

--for sintetic data change schema to mo;

ALTER TABLE temp1 ADD COLUMN new_id2 serial PRIMARY KEY;
--RETURN 'Selection table was created';

ANALYZE temp1;

END;
$$
LANGUAGE plpgsql VOLATILE
COST  100;

