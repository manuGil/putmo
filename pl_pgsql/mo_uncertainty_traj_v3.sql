
CREATE OR REPLACE FUNCTION pedestrians.mo_uncertainty_traj(from_schema text, data_set text, trip text, srid int, pix_size double precision, sigma double precision, sig_ratio real)
RETURNS void AS
$$

-- parameter: trip text, sigma double precision, sig_ratio double precision


DECLARE

_data_set text;
id_first integer;
id_last integer;
_confidence double precision;
_from_schema text;
_srid int;

BEGIN

_data_set:= data_set;

_from_schema:=from_schema;
_srid:=srid;


-- select all the point of a point in a trajectory:
PERFORM pedestrians.mo_selection(trip,_from_schema::text, _data_set::text);

-- create table to store probability values for individual segments:
PERFORM pedestrians.mo_temprasterseg(_srid);



id_first:= (SELECT t.new_id2 FROM temp1 AS t ORDER BY t.new_id2 ASC LIMIT 1)::integer;


id_last:= (SELECT t.new_id2 FROM temp1 AS t ORDER BY t.new_id2 DESC LIMIT 1)::integer;



-- COMPUTE uncertainty along a segment:


	WHILE id_first < id_last
		LOOP

		PERFORM pedestrians.mo_insert_UncertValues(id_first, id_first+1, pix_size, sigma, sig_ratio, _srid);

		id_first:= id_first+1;
		END LOOP;


--droping temporal table:
DROP TABLE temp1;

--Temporal Raster is drop later


END;
$$
LANGUAGE plpgsql VOLATILE
COST 200;

