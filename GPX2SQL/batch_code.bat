set PGPORT='port'
set PGHOST='host'
set PGUSER=postgres
set PGPASSWORD='password'
set THEDB= 'database name'
set PGBIN= 'path to PostgreSQL\9.1\bin'
set OGR= 'path to ogr2org driver'
set DATADIR= 'data directory'
set RETRIVETYPE= track_points
set SRS= 'WKT file for SRS transformation'
set FLIST= 'list of file names'
set EXTFILE=.gpx 
"%PGBIN%\psql"  -d "%THEDB%" -c "CREATE SCHEMA temp"
set SCHEM=temp
for %%f in (%FLIST%) DO "%OGR%\ogr2ogr" -t_srs "%SRS%" -f "PostgreSQL" PG:"host=%PGHOST% user=%PGUSER% port=%PGPORT% dbname=%THEDB% password=%PGPASSWORD%" "%DATADIR%\%%f%EXTFILE%" -overwrite -lco GEOMETRY_NAME=the_geom -lco SCHEMA=%SCHEM% %RETRIVETYPE% -nln "t%%f"
for %%f in (%FLIST%) DO "%PGBIN%\psql"  -d "%THEDB%" -c "ALTER TABLE "%SCHEM%.t%%f" ADD COLUMN tripid character varying (50)"
for %%f in (%FLIST%) DO "%PGBIN%\psql"  -d "%THEDB%" -c "UPDATE "%SCHEM%.t%%f" SET tripid='%%f'"
"%PGBIN%\psql"  -d "%THEDB%" -c "CREATE SCHEMA clean_data"
"%PGBIN%\psql"  -d "%THEDB%" -f "C:\gisdata\new_table.sql"
for %%f in (%FLIST%) DO "%PGBIN%\psql"  -d "%THEDB%" -c "INSERT INTO "clean_data"."valid_tracks" (tripid, the_geom,track_seg_point_id,elev,time_,desc_) SELECT tripid, the_geom, track_seg_point_id, ele, time, 'desc' FROM "%SCHEM%.t%%f""
"%PGBIN%\psql"  -d "%THEDB%" -c "VACUUM ANALYZE"
pause