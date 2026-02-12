-- name: CreateFlow :one
INSERT INTO flows (
  title,
  category_id,
  client_id,
  import_template_id,
  export_template_id
) VALUES (
  $1, $2, $3, $4, $5
) RETURNING *;

-- name: GetFlow :one
SELECT * FROM flows
WHERE id = $1 LIMIT 1;

-- name: UpdateFlow :one
UPDATE flows SET
  title = $2,
  import_template_id = $3,
  export_template_id = $4,
  updated_at = now()
WHERE id = $1
RETURNING *;

-- name: ListFlows :many
SELECT * FROM flows
WHERE client_id IS NULL OR client_id = $1;

-- name: DeleteFlow :exec
DELETE FROM flows WHERE id = $1;

-- name: CreateFlowEnrich :one
INSERT INTO flow_enriches (
  flow_id,
  template_order,
  enrich_template_id
) VALUES (
  $1, $2, $3
) RETURNING *;

-- name: GetFlowEnrichs :many
SELECT * FROM flow_enriches
WHERE flow_id = $1;

-- name: DeleteFlowEnrich :exec
DELETE FROM flow_enriches
WHERE flow_id = $1 AND enrich_template_id = $2;
