CREATE OR REPLACE FUNCTION keepcoding.clean_integer(input INT64) RETURNS INT64 AS (
  IF(input IS NULL, -999999, input)
);