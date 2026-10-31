
USE pandemic;

SELECT COUNT(*) AS imported_rows FROM infectious_cases_raw;
SELECT * FROM infectious_cases_raw LIMIT 10;


CREATE TABLE entities (
    entity_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    Entity VARCHAR(100) NOT NULL UNIQUE,
    Code VARCHAR(16)
);

INSERT INTO entities (Entity, Code)
SELECT DISTINCT Entity, NULLIF(TRIM(Code), '')
FROM infectious_cases_raw
ORDER BY Entity;

CREATE TABLE infectious_cases (
    entity_id INT UNSIGNED NOT NULL,
    Year SMALLINT UNSIGNED NOT NULL,
    Number_yaws DECIMAL(24, 12),
    polio_cases DECIMAL(24, 12),
    cases_guinea_worm DECIMAL(24, 12),
    Number_rabies DECIMAL(24, 12),
    Number_malaria DECIMAL(24, 12),
    Number_hiv DECIMAL(24, 12),
    Number_tuberculosis DECIMAL(24, 12),
    Number_smallpox DECIMAL(24, 12),
    Number_cholera_cases DECIMAL(24, 12),
    PRIMARY KEY (entity_id, Year),
    CONSTRAINT fk_cases_entity
        FOREIGN KEY (entity_id) REFERENCES entities(entity_id)
);

INSERT INTO infectious_cases (
    entity_id, Year, Number_yaws, polio_cases, cases_guinea_worm,
    Number_rabies, Number_malaria, Number_hiv, Number_tuberculosis,
    Number_smallpox, Number_cholera_cases
)
SELECT
    e.entity_id,
    CAST(r.Year AS UNSIGNED),
    CAST(NULLIF(TRIM(r.Number_yaws), '') AS DECIMAL(24, 12)),
    CAST(NULLIF(TRIM(r.polio_cases), '') AS DECIMAL(24, 12)),
    CAST(NULLIF(TRIM(r.cases_guinea_worm), '') AS DECIMAL(24, 12)),
    CAST(NULLIF(TRIM(r.Number_rabies), '') AS DECIMAL(24, 12)),
    CAST(NULLIF(TRIM(r.Number_malaria), '') AS DECIMAL(24, 12)),
    CAST(NULLIF(TRIM(r.Number_hiv), '') AS DECIMAL(24, 12)),
    CAST(NULLIF(TRIM(r.Number_tuberculosis), '') AS DECIMAL(24, 12)),
    CAST(NULLIF(TRIM(r.Number_smallpox), '') AS DECIMAL(24, 12)),
    CAST(NULLIF(TRIM(r.Number_cholera_cases), '') AS DECIMAL(24, 12))
FROM infectious_cases_raw AS r
JOIN entities AS e
    ON r.Entity = e.Entity
    AND NULLIF(TRIM(r.Code), '') <=> e.Code;


SELECT COUNT(*) FROM infectious_cases;
SELECT COUNT(*) AS entities_count FROM entities;
SELECT * FROM entities ORDER BY entity_id LIMIT 10;
SELECT entity_id, Year, Number_rabies
FROM infectious_cases
ORDER BY entity_id, Year
LIMIT 10;


SELECT
    e.Entity,
    e.Code,
    AVG(c.Number_rabies) AS avg_rabies,
    MIN(c.Number_rabies) AS min_rabies,
    MAX(c.Number_rabies) AS max_rabies,
    SUM(c.Number_rabies) AS sum_rabies
FROM infectious_cases AS c
JOIN entities AS e ON c.entity_id = e.entity_id
WHERE c.Number_rabies IS NOT NULL
GROUP BY e.entity_id, e.Entity, e.Code
ORDER BY avg_rabies DESC, e.entity_id
LIMIT 10;


SELECT
    entity_id,
    Year,
    MAKEDATE(Year, 1) AS year_start,
    CURDATE() AS current_date_value,
    TIMESTAMPDIFF(YEAR, MAKEDATE(Year, 1), CURDATE()) AS years_difference
FROM infectious_cases
ORDER BY entity_id, Year;


CREATE FUNCTION years_since(p_year INT)
RETURNS INT
NOT DETERMINISTIC
NO SQL
RETURN TIMESTAMPDIFF(YEAR, MAKEDATE(p_year, 1), CURDATE());

SELECT
    entity_id,
    Year,
    years_since(Year) AS years_difference
FROM infectious_cases
ORDER BY entity_id, Year;


SELECT
    (SELECT COUNT(*) FROM infectious_cases_raw) AS raw_rows,
    (SELECT COUNT(*) FROM infectious_cases) AS normalized_rows,
    (SELECT COUNT(*) FROM entities) AS entities_count;

SELECT
    SUM(Number_rabies IS NULL) AS missing_rabies,
    COUNT(Number_rabies) AS present_rabies
FROM infectious_cases;

SELECT COUNT(*) AS function_mismatches
FROM infectious_cases
WHERE NOT (
    years_since(Year) <=>
    TIMESTAMPDIFF(YEAR, MAKEDATE(Year, 1), CURDATE())
);

SELECT
    1996 AS example_year,
    MAKEDATE(1996, 1) AS year_start,
    CURDATE() AS current_date_value,
    years_since(1996) AS years_difference;
