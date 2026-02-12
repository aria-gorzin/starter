-- name: CreateSearchHistory :one
INSERT INTO search_histories (
  user_id,
  client_id,
  category_id,
  filters,
  sort
) VALUES (
  $1, $2, $3, $4, $5
) RETURNING *;

-- name: ListSearchHistories :many
SELECT * FROM search_histories
WHERE
    client_id = sqlc.arg(client_id)
    AND (sqlc.narg(category_id) IS NULL OR category_id = sqlc.narg(category_id))
    AND (sqlc.narg(user_id) IS NULL OR user_id = sqlc.narg(user_id))
    AND (sqlc.narg(created_at_start) IS NULL OR created_at >= sqlc.narg(created_at_start))
    AND (sqlc.narg(created_at_end) IS NULL OR created_at <= sqlc.narg(created_at_end))
ORDER BY created_at DESC
LIMIT sqlc.arg(per_page) OFFSET sqlc.arg(skip);

-- name: GetLastSearchHistory :one
SELECT * FROM search_histories
WHERE client_id = sqlc.arg(client_id)
ORDER BY created_at DESC LIMIT 1;
