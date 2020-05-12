CREATE OR REPLACE FUNCTION pedestrians.mo_sigMax(sigma double precision, s_ratio real,  t_start timestamp with time zone,t_end timestamp with time zone)
RETURNS double precision AS
$BODY$

DECLARE

s_ratio real:= s_ratio; --chage in sigma given a change in time (time interval) in percentage. the slope
t_int interval; --time interval between  consecutive points
s_max double precision;
int_sec integer;
sigma double precision:=sigma;

BEGIN
s_max:=sigma;

	IF s_ratio <> 0::double precision THEN
		t_int:= (t_end - t_start)::interval;

		--convert time interval to seconds:
		/*int_sec:= ((extract(minute from t_int)::integer)*60 + (extract(second from t_int)::integer))::integer;
*/
				int_sec:= ((extract(hour from t_int))*3600 + (extract(minute from t_int))*60 + (extract(second from t_int)))::integer;

		s_max:= ((s_ratio/100 * int_sec) + sigma)::double precision;
	END IF;
	
RAISE NOTICE 'time inverval in seconds: %; s_max: %', int_sec, s_max;

RETURN s_max;


END;

$BODY$

LANGUAGE plpgsql IMMUTABLE STRICT
COST 100;
