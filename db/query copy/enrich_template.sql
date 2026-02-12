-- name: CreateEnrichTemplate :one
INSERT INTO enrich_templates (
  title,
  attribute_id,
  category_id,
  client_id,
  type,
  value,
  params
) VALUES (
  $1, $2, $3, $4, $5, $6, $7
) RETURNING *;

-- name: GetEnrichTemplate :one
SELECT * FROM enrich_templates
WHERE id = $1 LIMIT 1;

-- name: UpdateEnrichTemplate :one
UPDATE enrich_templates
SET
    title = $2,
    type = $3,
    value = $4,
    params = $5,
    updated_at = now()
WHERE
    id = $1
RETURNING *;

-- name: ListEnrichTemplates :many
SELECT * FROM enrich_templates
WHERE client_id IS NULL OR client_id = $1;

-- name: DeleteEnrichTemplate :exec
DELETE FROM enrich_templates
WHERE id = $1;
