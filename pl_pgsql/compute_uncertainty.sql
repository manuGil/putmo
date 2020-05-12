set search_path=  public, pedestrians; % --specify  or modify any other Schema that contains function or data 

--THE FOLLOWING QUERY creates PGRaster file with name 'ras_"trip id"' into the 'to schema' schema.
SELECT pedestrians.mo_unionseg(
'schema', --from schema
'schema', --to schema
'waypoints', --input dataset as a set of points with table schema as in 'sample_data.sql' file
'150', -- trip id
28992, -- SRS. Only two SRS are supported RD_new (for The Netherlands) and 23662 as global projection.

0.2, --pixel size in meters
3.0, --sigma in meters
3.0 -- sigma ratio %
);