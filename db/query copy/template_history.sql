-- name: CreateTemplateHistory :one
INSERT INTO template_histories (
  user_id,
  client_id,
  category_id,
  template_type,
  template_id
) VALUES (
  $1, $2, $3, $4, $5
) RETURNING *;

-- name: ListTemplateHistories :many
SELECT * FROM template_histories
WHERE
    template_histories.client_id = sqlc.arg(client_id)
    AND (sqlc.narg(category_id) IS NULL OR template_histories.category_id = sqlc.narg(category_id))
    AND (sqlc.narg(template_type) IS NULL OR template_histories.template_type = sqlc.narg(template_type))
    AND (sqlc.narg(template_id) IS NULL OR template_histories.template_id = sqlc.narg(template_id))
    AND (sqlc.narg(user_id) IS NULL OR template_histories.user_id = sqlc.narg(user_id))
    AND (sqlc.narg(created_at_start) IS NULL OR template_histories.created_at >= sqlc.narg(created_at_start))
    AND (sqlc.narg(created_at_end) IS NULL OR template_histories.created_at <= sqlc.narg(created_at_end))
ORDER BY created_at DESC
LIMIT sqlc.arg(per_page) OFFSET sqlc.arg(skip);

-- name: GetLastTemplateHistory :one
SELECT * FROM template_histories
WHERE
    template_histories.client_id = sqlc.arg(client_id)
    AND template_histories.template_type = sqlc.arg(template_type)
ORDER
    BY created_at DESC LIMIT 1;
