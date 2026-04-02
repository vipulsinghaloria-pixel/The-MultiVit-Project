--1. Show whether each nutrient in MuscleBlaze is sufficient or insufficient compared to daily requirement
SELECT multivit."Nutrients",
       multivit."HK Vitals ",
       multivit3."PerDayNutReq",
       CASE
           WHEN multivit."HK Vitals " >= multivit3."PerDayNutReq" THEN 'Sufficient'
           ELSE 'Insufficient'
       END AS Status
FROM multivit
JOIN multivit3 ON multivit."Nutrients" = multivit3."Nutrients";

--2. Calculate total nutrients for each brand.


WITH totals AS (
    SELECT SUM("MuscleBlaze ") AS MB_Total,
           SUM("HK Vitals ") AS HK_Total,
           SUM("Carbamide ") AS Carbamide_Total
    FROM multivit
    WHERE "Nutrients" <> 'Price (INR)'
)
SELECT * FROM totals;

-- 3. Rank nutrients by HK Vitals values

SELECT "Nutrients", "HK Vitals ",
       RANK() OVER (ORDER BY "HK Vitals " DESC) AS HK_Rank
FROM multivit
WHERE "Nutrients" <> 'Price (INR)';

-- 4. List nutrients missing in HK Vitals or Carbamide
SELECT "Nutrients", 'HK Vitals' AS Brand
FROM multivit
WHERE "HK Vitals " = 0
UNION
SELECT "Nutrients", 'Carbamide'
FROM multivit
WHERE "Carbamide " = 0;


-- 5. Show cost per nutrient for each brand
SELECT 'MuscleBlaze' AS Brand,
       (SELECT "MuscleBlaze " FROM multivit WHERE "Nutrients"='Price (INR)')
       / SUM("MuscleBlaze ") AS Cost_Per_Nutrient
FROM multivit WHERE "MuscleBlaze " > 0
UNION
SELECT 'HK Vitals',
       (SELECT "HK Vitals " FROM multivit WHERE "Nutrients"='Price (INR)')
       / SUM("HK Vitals ")
FROM multivit WHERE "HK Vitals " > 0
UNION
SELECT 'Carbamide',
       (SELECT "Carbamide " FROM multivit WHERE "Nutrients"='Price (INR)')
       / SUM("Carbamide ")
FROM multivit WHERE "Carbamide " > 0;



-- 6. Show nutrients where HK Vitals meets or exceeds daily requirement
WITH hk_high AS (
    SELECT m."Nutrients", m."HK Vitals ", r."PerDayNutReq"
    FROM multivit m
    JOIN multivit3 r ON m."Nutrients" = r."Nutrients"
    WHERE m."HK Vitals " >= r."PerDayNutReq"
)
SELECT * FROM hk_high;

--  7. Calculate cumulative totals for MuscleBlaze nutrients
SELECT m."Nutrients",
       m."MuscleBlaze ",
       r."PerDayNutReq",
       CASE
           WHEN m."MuscleBlaze " >= r."PerDayNutReq" THEN 'Sufficient'
           ELSE 'Insufficient'
       END AS Status
FROM multivit m
JOIN multivit3 r ON m."Nutrients" = r."Nutrients";

-- 8.  Show average nutrient values for each brand
SELECT 'MuscleBlaze' AS Brand, AVG("MuscleBlaze ") AS Avg_Val
FROM "multivit" WHERE "Nutrients" <> 'Price (INR)'
UNION
SELECT 'HK Vitals', AVG("HK Vitals ")
FROM "multivit" WHERE "Nutrients" <> 'Price (INR)'
UNION
SELECT 'Carbamide', AVG("Carbamide ")
FROM "multivit" WHERE "Nutrients" <> 'Price (INR)';


-- 9.  Identify strongest brand for each nutrient
SELECT m."Nutrients",
    CASE
        WHEN m."MuscleBlaze " >= m."HK Vitals " AND m."MuscleBlaze " >= m."Carbamide " THEN 'MuscleBlaze'
        WHEN m."HK Vitals " >= m."MuscleBlaze " AND m."HK Vitals " >= m."Carbamide " THEN 'HK Vitals'
        ELSE 'Carbamide'
    END AS Strongest_Brand
FROM multivit m
WHERE m."Nutrients" <> 'Price (INR)';


-- 10. Show percentage contribution of each brand per nutrient and rank them
WITH nutrient_data AS (
    SELECT m."Nutrients", m."MuscleBlaze ", m."HK Vitals ", m."Carbamide ", r."PerDayNutReq"
    FROM multivit m
    JOIN multivit3 r ON m."Nutrients" = r."Nutrients"
    WHERE m."Nutrients" <> 'Price (INR)'
)
SELECT "Nutrients", 'MuscleBlaze' AS Brand,
    ROUND(("MuscleBlaze "*100.0/"PerDayNutReq"),2) AS Percent_Contribution,
    RANK() OVER (PARTITION BY "Nutrients" ORDER BY "MuscleBlaze " DESC) AS Rank
FROM nutrient_data
UNION ALL
SELECT "Nutrients", 'HK Vitals',
    ROUND(("HK Vitals "*100.0/"PerDayNutReq"),2),
    RANK() OVER (PARTITION BY "Nutrients" ORDER BY "HK Vitals " DESC)
FROM nutrient_data
UNION ALL
SELECT "Nutrients", 'Carbamide',
    ROUND(("Carbamide "*100.0/"PerDayNutReq"),2),
    RANK() OVER (PARTITION BY "Nutrients" ORDER BY "Carbamide " DESC)
FROM nutrient_data;

SELECT * FROM multivit2



-- 11. Calculate Average Ratings Across Platforms

SELECT 'MuscleBlaze' AS Brand,
       AVG("MuscleBlaze") AS AvgRating
FROM multivit2
WHERE "Properties" LIKE '%Ratings%'
UNION
SELECT 'HKVitals',
       AVG("HKVitals")
FROM multivit2
WHERE "Properties" LIKE '%Ratings%'
UNION
SELECT 'Carbamide',
       AVG("Carbamide")
FROM multivit2
WHERE "Properties" LIKE '%Ratings%';















