-- name: CreateClient :one
INSERT INTO clients (
  title,
  status
) VALUES (
  $1, $2
) RETURNING *;

-- name: GetClient :one
SELECT * FROM clients
WHERE id = $1 LIMIT 1;

-- name: UpdateClient :one
UPDATE clients
SET
  title = $2,
  status = $3,
  updated_at = now()
WHERE
  id = $1
RETURNING *;

-- name: ListClients :many
SELECT * FROM clients
WHERE
  (sqlc.narg(title)::text IS NULL OR title ILIKE '%' || sqlc.narg(title)::text || '%')
  AND (sqlc.narg(status)::text IS NULL OR status = sqlc.narg(status)::text)
  AND (sqlc.narg(created_at_start)::timestamptz IS NULL OR created_at >= sqlc.narg(created_at_start)::timestamptz)
  AND (sqlc.narg(created_at_end)::timestamptz IS NULL OR created_at <= sqlc.narg(created_at_end)::timestamptz)
ORDER BY
  CASE
    WHEN sqlc.narg(sort)::text = 'title' AND sqlc.narg(sort_direction)::text = 'asc' THEN title
  END ASC,
  CASE
    WHEN sqlc.narg(sort)::text = 'title' THEN title
  END DESC,
  CASE
    WHEN sqlc.narg(sort)::text = 'created_at' AND sqlc.narg(sort_direction)::text = 'asc' THEN created_at
  END ASC,
  CASE
    WHEN sqlc.narg(sort)::text = 'created_at' THEN created_at
  END DESC,
  id DESC
LIMIT sqlc.arg(per_page) OFFSET sqlc.arg(skip);

-- name: CountClients :one
SELECT count(id) FROM clients
WHERE
  (sqlc.narg(title)::text IS NULL OR title ILIKE '%' || sqlc.narg(title)::text || '%')
  AND (sqlc.narg(status)::text IS NULL OR status = sqlc.narg(status)::text)
  AND (sqlc.narg(created_at_start)::timestamptz IS NULL OR created_at >= sqlc.narg(created_at_start)::timestamptz)
  AND (sqlc.narg(created_at_end)::timestamptz IS NULL OR created_at <= sqlc.narg(created_at_end)::timestamptz);


-- name: DeleteClient :exec
DELETE FROM clients
WHERE id = $1;