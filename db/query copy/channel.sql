-- name: CreateChannel :one
INSERT INTO channels (
  client_id,
  title,
  type,
  config,
  status
) VALUES (
  $1, $2, $3, $4, $5
) RETURNING *;

-- name: GetChannel :one
SELECT * FROM channels
WHERE id = $1 LIMIT 1;

-- name: UpdateChannel :one
UPDATE channels
SET
  title = $2,
  type = $3,
  config = $4,
  status = $5,
  updated_at = now()
WHERE
  id = $1
RETURNING *;

-- name: ListChannels :many
SELECT * FROM channels
WHERE client_id IS NULL OR client_id = $1;

-- name: DeleteChannel :exec
DELETE FROM channels
WHERE id = $1;
