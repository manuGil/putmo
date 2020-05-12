CREATE OR REPLACE FUNCTION pedestrians.mo_obb(start_point geometry, end_point geometry, sigma_max double precision)
RETURNS geometry AS

/* Using the build-in BUFFER function to bound the extend the
computation of the uncertainty values aroud a trajectory segment.
Sigma represent the standar deviation and is used to comput the
least max radius around the trajectory segment. Confidence represents
the conficence level in percentage.

line segment should be provided as line.
*/

$BODY$
DECLARE

z double precision; 
sigma_max double precision:= sigma_max;
line_seg geometry;
obb geometry;
r double precision;

BEGIN




-- Look for Z scores in look up table:
--z:= (SELECT z.z_value FROM pedestrians.z_scores AS z WHERE z.confidence=_confidence)::double precision;

z:=3.4807;
RAISE NOTICE 'z value set to: %', z;

r:= (z*sigma_max)+ sigma_max*0.1; -- the constant 0.1 extends the radius of the buffer, 10% of sigma.


--obb:= ST_Buffer(ST_MakeLine(ST_setsrid(ST_MakePoint(Xo,Yo),28992),St_setsrid(ST_MakePoint(X1,Y1),28992)), r, 'endcap=square');

obb:=ST_Buffer(ST_MakeLine(start_point, end_point), r, 'endcap=square');



RETURN obb;


END;
$BODY$
LANGUAGE plpgsql IMMUTABLE
COST 100;
