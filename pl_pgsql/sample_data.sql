

CREATE TABLE pedestrians.sinthetic AS
	SELECT t.* FROM pedestrians.sinthetic AS t WHERE t.gid!=t.gid;

ALTER TABLE pedestrians.sinthetic ADD PRIMARY KEY (gid);



INSERT INTO pedestrians.sinthetic VALUES (1, '100'::varchar, st_geometryfromtext('POINT(84300 447300)',28992),
				1, 4.95, '2013-07-16 17:00:00+1'::timestamp with time zone,
				'speed 1 m/s');

INSERT INTO pedestrians.sinthetic VALUES (2, '100'::varchar, st_geometryfromtext('POINT(84370.71 447370.71)',28992),
				2, 4.85, '2013-07-16 17:01:40+1'::timestamp with time zone,
				'speed 1 m/s');
select * pedestrians.sinthetic;