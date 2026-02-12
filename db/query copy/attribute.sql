-- name: CreateAttribute :one
INSERT INTO attributes (
  title,
  type,
  client_id,
  min,
  max,
  format,
  regex,
  allowed_values,
  status
) VALUES (
  $1, $2, $3, $4, $5, $6, $7, $8, $9
) RETURNING *;

-- name: GetAttribute :one
SELECT * FROM attributes
WHERE id = $1 LIMIT 1;

-- name: UpdateAttribute :one
UPDATE attributes
SET
  title = $2,
  type = $3,
  status = $4,
  min = $5,
  max = $6,
  format = $7,
  regex = $8,
  allowed_values = $9,
  updated_at = now()
WHERE
  id = $1
RETURNING *;

-- name: ListAttributes :many
SELECT * FROM attributes
WHERE client_id is NULL OR client_id = $1;

-- name: DeleteAttribute :exec
DELETE FROM attributes
WHERE id = $1;
