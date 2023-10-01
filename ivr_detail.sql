CREATE OR REPLACE TABLE keepcoding.ivr_detail AS
SELECT
  c.ivr_id AS calls_ivr_id,
  c.phone_number AS calls_phone_number,
  c.ivr_result AS calls_ivr_result,
  c.vdn_label AS calls_vdn_label,
  c.start_date AS calls_start_date,
  EXTRACT(YEAR FROM c.start_date)*10000 + EXTRACT(MONTH FROM c.start_date)*100 + EXTRACT(DAY FROM c.start_date) AS calls_start_date_id,
  c.end_date AS calls_end_date,
  EXTRACT(YEAR FROM c.end_date)*10000 + EXTRACT(MONTH FROM c.end_date)*100 + EXTRACT(DAY FROM c.end_date) AS calls_end_date_id,
  TIMESTAMP_DIFF(c.end_date, c.start_date, SECOND) AS calls_total_duration,
  c.customer_segment AS calls_customer_segment,
  c.ivr_language AS calls_ivr_language,
  m.module_sequece AS module_sequece,  
  m.module_name AS module_name,
  m.module_duration AS module_duration,
  m.module_result AS module_result,
  s.step_sequence AS step_sequence,
  s.step_name AS step_name,
  s.step_result AS step_result,
  s.step_description_error AS step_description_error,
  s.document_type AS document_type,
  s.document_identification AS document_identification,
  s.customer_phone AS customer_phone,
  s.billing_account_id AS billing_account_id
FROM
  keepcoding.ivr_calls AS c
JOIN
  keepcoding.ivr_modules AS m ON c.ivr_id = m.ivr_id
JOIN
  keepcoding.ivr_steps AS s ON m.ivr_id = s.ivr_id AND m.module_sequece = s.module_sequece;  
