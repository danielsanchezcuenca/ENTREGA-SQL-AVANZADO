CREATE OR REPLACE TABLE keepcoding.ivr_summary AS
WITH RepeatedPhone24H AS (
  SELECT
    a.calls_phone_number,
    a.calls_start_date
  FROM
    keepcoding.ivr_detail a
  WHERE
    EXISTS (
      SELECT 1
      FROM keepcoding.ivr_detail b
      WHERE
        a.calls_phone_number = b.calls_phone_number
        AND TIMESTAMP_DIFF(a.calls_start_date, b.calls_start_date, SECOND) BETWEEN 1 AND 86400
        AND a.calls_ivr_id != b.calls_ivr_id
    )
),
CauseRecallPhone24H AS (
  SELECT
    a.calls_phone_number,
    a.calls_start_date
  FROM
    keepcoding.ivr_detail a
  WHERE
    EXISTS (
      SELECT 1
      FROM keepcoding.ivr_detail b
      WHERE
        a.calls_phone_number = b.calls_phone_number
        AND TIMESTAMP_DIFF(b.calls_start_date, a.calls_start_date, SECOND) BETWEEN 1 AND 86400
        AND a.calls_ivr_id != b.calls_ivr_id
    )
)
SELECT
  d.calls_ivr_id,
  MAX(d.module_name) as module_name,
  MAX(d.step_name) as step_name,
  MAX(d.step_description_error) as step_description_error,
  MAX(d.calls_phone_number) as calls_phone_number,
  MAX(d.calls_ivr_result) as calls_ivr_result,
  CASE
    WHEN MAX(LEFT(d.calls_vdn_label, 3)) = 'ATC' THEN 'FRONT'
    WHEN MAX(LEFT(d.calls_vdn_label, 4)) = 'TECH' THEN 'TECH'
    WHEN MAX(d.calls_vdn_label) = 'ABSORPTION' THEN 'ABSORPTION'
    ELSE 'RESTO'
  END as vdn_aggregation,
  MIN(d.calls_start_date) as calls_start_date,
  MAX(d.calls_end_date) as calls_end_date,
  SUM(d.calls_total_duration) as calls_total_duration,
  MAX(d.calls_customer_segment) as calls_customer_segment,
  MAX(d.calls_ivr_language) as calls_ivr_language,
  COUNT(DISTINCT d.module_name) as steps_module,
  STRING_AGG(DISTINCT d.module_name) as module_aggregation,
  MAX(d.document_type) as document_type,
  MAX(d.document_identification) as document_identification,
  MAX(d.customer_phone) as customer_phone,
  MAX(d.billing_account_id) as billing_account_id,
  MAX(CASE WHEN d.module_name = 'AVERIA_MASIVA' THEN 1 ELSE 0 END) as masiva_lg,
  MAX(CASE WHEN d.step_name = 'CUSTOMERINFOBYPHONE.TX' AND d.step_description_error = 'NULL' THEN 1 ELSE 0 END) as info_by_phone_lg,
  MAX(CASE WHEN d.step_name = 'CUSTOMERINFOBYDNI.TX' AND d.step_description_error = 'NULL' THEN 1 ELSE 0 END) as info_by_dni_lg,
  IF(MAX(rep.calls_phone_number) IS NOT NULL, 1, 0) AS repeated_phone_24H,
  IF(MAX(rec.calls_phone_number) IS NOT NULL, 1, 0) AS cause_recall_phone_24H
FROM
  keepcoding.ivr_detail d
LEFT JOIN RepeatedPhone24H rep ON d.calls_phone_number = rep.calls_phone_number AND d.calls_start_date = rep.calls_start_date
LEFT JOIN CauseRecallPhone24H rec ON d.calls_phone_number = rec.calls_phone_number AND d.calls_start_date = rec.calls_start_date
GROUP BY
  d.calls_ivr_id;
