-- name: CreateCommit :one
INSERT INTO commits (user_id, client_id, parent_id, message)
VALUES ($1, $2, $3, $4)
RETURNING *;

-- name: GetCommit :one
SELECT * FROM commits
WHERE id = $1;

-- name: GetByParentId :one
SELECT * FROM commits
WHERE parent_id = $1
LIMIT 1;

-- name: ListCommits :many
SELECT * FROM commits
WHERE
    (sqlc.narg(user_id) IS NULL OR user_id = sqlc.narg(user_id))
    AND (sqlc.narg(client_id) IS NULL OR client_id = sqlc.narg(client_id))
    AND (sqlc.narg(created_at_start) IS NULL OR created_at >= sqlc.narg(created_at_start))
    AND (sqlc.narg(created_at_end) IS NULL OR created_at <= sqlc.narg(created_at_end))
ORDER BY created_at DESC
LIMIT sqlc.arg(per_page) OFFSET sqlc.arg(skip);

-- name: ListProductCommits :many
SELECT
    pv.id AS product_version_id,
    pv.action,
    c.id AS commit_id,
    c.message,
    c.created_at,
    c.client_id,
    c.user_id,
    u.full_name
FROM
    product_versions pv
JOIN
    commits c ON pv.commit_id = c.id
JOIN
    users u ON c.user_id = u.id
WHERE
    pv.product_id = $1;

-- name: UpsertCommitHead :one
INSERT INTO commit_heads (client_id, commit_id)
VALUES ($1, $2)
ON CONFLICT (client_id) 
DO UPDATE SET commit_id = $2
RETURNING *;

-- name: GetCommitHead :one
SELECT * FROM commit_heads
WHERE client_id = $1;

-- name: UpsertLatestCommit :one
INSERT INTO latest_commits (client_id, commit_id)
VALUES ($1, $2)
ON CONFLICT (client_id)
DO UPDATE SET commit_id = $2
RETURNING *;

-- name: GetLatestCommit :one
SELECT * FROM latest_commits
WHERE client_id = $1;