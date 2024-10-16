/*
-- TABLE SCHEMA
CREATE TABLE GTP_A1 (
	path varchar(200),
	symbol varchar(50),
	contract varchar(400),
	works boolean,
	benchmark_name varchar(100)
);
UPDATE GTP_A1 SET benchmark_name = SUBSTRING(path, 0, STRPOS(path, '/')) -- parse the benchmark name out of the path
ALTER TABLE GTP_A1 ADD CONSTRAINT PK_GTP_A1 PRIMARY KEY (path,symbol)
*/

-- works/total by benchmark
SELECT 
	benchmark_name
	,SUM( CASE WHEN works THEN 1 ELSE NULL END) "crg-works?"
	,COUNT(*) total
	,1.0 * SUM( CASE WHEN works THEN 1 ELSE NULL END) / COUNT(*) percent
FROM GTP_A1
GROUP BY benchmark_name
ORDER BY 1.0 * SUM( CASE WHEN works THEN 1 ELSE NULL END) / COUNT(*) ASC;
/*
RESULT: 1279 out of 1833 total (~70%) of non-flat contracts in gtp-benchmarks are handled by contract-random-generate.
Here is the breakdown by benchmark (sorted from least to most coverage):

"fsmoo-configurations"	3	11	0.27
"quadT-configurations"	63	117	0.53
"quadU-configurations"	63	115	0.54
"zordoz-configurations"	475	847	0.56
"dungeon-configurations"	10	16	0.62
"synth-configurations"	38	51	0.74
"jpeg-configurations"	32	41	0.78
"take5-configurations"	15	19	0.78
"lnm-configurations"	30	35	0.85
"acquire-configurations"	112	125	0.89
"zombie-configurations"	14	15	0.93
"suffixtree-configurations"	73	78	0.93
"gregor-configurations"	140	148	0.94
"fsm-configurations"	24	25	0.96
"kcfa-configurations"	72	74	0.97
"snake-configurations"	28	28	1.00
"forth-configurations"	7	7	1.00
"tetris-configurations"	58	58	1.00
"sieve-configurations"	7	7	1.00
"morsecode-configurations"	15	15	1.00
"mbta-configurations"	0	1	0	
*/


WITH not_crg AS (
	SELECT 
		benchmark_name
		,symbol
		,contract
		,contract LIKE '%->*%' opt_kw_function
		,contract LIKE '%vector%' vector
		,contract LIKE '%parameter%' parameter_
		,contract LIKE '%mark%' mark
		,contract LIKE '%stx%' stx
		,contract LIKE '%struct%shape%' struct_shape
	FROM GTP_A1
	WHERE NOT works 
)
-- list all 'none of the above '
/*SELECT *
FROM not_crg
WHERE NOT (opt_kw_function OR vector OR parameter_ OR mark OR stx OR struct_shape)*/
-- counts
SELECT 
	COUNT(*) total
	,SUM(CASE WHEN opt_kw_function THEN 1 ELSE NULL END) "opt_kw_function_count"
	,SUM(CASE WHEN vector THEN 1 ELSE NULL END) "vector_count"
	,SUM(CASE WHEN parameter_ THEN 1 ELSE NULL END) "parameter__count"
	,SUM(CASE WHEN mark THEN 1 ELSE NULL END) "mark_count"
	,SUM(CASE WHEN stx THEN 1 ELSE NULL END) "stx_count"
	,SUM(CASE WHEN struct_shape THEN 1 ELSE NULL END) "struct_shape_count"
	,SUM(CASE WHEN (opt_kw_function OR vector OR parameter_ OR mark OR stx OR struct_shape) THEN NULL ELSE 1 END) "none_of_the_above"
FROM not_crg;
/*
RESULT:
There are 554 non-flat contract for whom contract-random-generate can't create a value. 
308 for unknown reasons; 78 due to optional/kw arg functions, etc. Cases are not mutally exclusive.

"total"	"opt_kw_function_count"	"vector_count"	"parameter__count"	"mark_count"	"stx_count"	"struct_shape_count"	"none_of_the_above"
554	78	50	42	22	36	30	308
*/
