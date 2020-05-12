CREATE OR REPLACE FUNCTION pedestrians.mo_probability_density(x double precision, y double precision, meanx double precision, meany double precision, sigma double precision)
  RETURNS double precision AS
$BODY$
--This function takes parameter x and y as variable, meanx, sigmax are parameter for x, similarly meany and sigmay for y, rho represents correlation coefficient.
  DECLARE
 
  probability_density double precision;
  sigmax double precision:=sigma;
  sigmay double precision:=sigma;
  --rho double precision:=0; --DONT NEED THIS
 -- initial_val double precision;
  

BEGIN


	BEGIN
	probability_density:= (1/(2.0*pi()*sigmax*sigmay))*exp
	(-((power((x-meanx),2) + power((y-meany),2))/(2*sigmax*		sigmay)));
	
	EXCEPTION
		WHEN numeric_value_out_of_range THEN
		RAISE NOTICE 'UNDERFLOW';
		probability_density:=0.00000;
	RETURN probability_density;

	END;
	
RETURN probability_density::double precision;

  END;
$BODY$
  LANGUAGE plpgsql IMMUTABLE STRICT
  COST 100;