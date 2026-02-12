-- name: CreateFunction :one
INSERT INTO functions (
  title,
  text,
  type,
  description,
  client_id,
  status
) VALUES (
  $1, $2, $3, $4, $5, $6
) RETURNING *;

-- name: GetFunction :one
SELECT * FROM functions
WHERE id = $1 LIMIT 1;

-- name: UpdateFunction :one
UPDATE functions SET
  title = $2,
  text = $3,
  type = $4,
  description = $5,
  status = $6,
  updated_at = now()
WHERE id = $1
RETURNING *;

-- name: ListFunctions :many
SELECT * FROM functions
WHERE client_id IS NULL OR client_id = $1;


-- name: DeleteFunction :exec
DELETE FROM functions
WHERE id = $1;
