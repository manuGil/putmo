CREATE TABLE "clean_data"."valid_tracks" (gid serial PRIMARY KEY,
            tripid character varying (50),
			the_geom geometry(Point,28992),
			track_seg_point_id integer, 
			elev double precision, 
			time_ timestamp with time zone, 
			desc_ character varying );