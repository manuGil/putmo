# putmo
A repository containing code for extending the functionality of the PostGIS extension, and a batch file for parsing GPX files and injecting data points into a PostgreSQL with the PostGIS extension.

The code was tested using GPS tracks of pedestrians visiting a city. For more informations refer to the reference below.

## Skils Acquired
* PL/pgSQL procedural programming
* Batch file programming
* Management of PostgreSQL databases
* Handling Raster datasets in PostgreSQL

## Use
Requires a running installatin of PostGIS 9.1 or higher and PostGIS 2.0 or higher. The execution of the PL/pgSQL files can be easily done using PgAdmin III. For visualization you need QuantumGIS Desktop and the plugin 'Load Postgis Raster to QGIS (Version 0.5.4) or similar.

### PL/pgSQL
- Clone or download the repository.
- In the database of interest create the Schema 'pedestrians'. The functions will be loaded in this schema.
- Load the individual *.sql files into the interface of pgAdmin III and execute. (One at the time).
- Functions can be called using the SQL editor of pgAdmin III.
- Uncertainty computations can be done by modifying the compute_uncertainty.sql file.

### 

## Reference
Manuel G. García, Ivana Ivánová, Arta Dilo, and Javier Morales. 2013. Representing positional uncertainty of individual and aggregated trajectories of moving objects. In Proceedings of the 21st ACM SIGSPATIAL International Conference on Advances in Geographic Information Systems (SIGSPATIAL’13). Association for Computing Machinery, New York, NY, USA, 436–439. DOI:https://doi.org/10.1145/2525314.2525454
