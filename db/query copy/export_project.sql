-- name: CreateExportProject :one
INSERT INTO export_projects (
  title,
  category_id,
  client_id,
  template_id,
  channel_id,
  filters,
  sort,
  delimiter,
  total_count,
  processed_count,
  error_count,
  step
) VALUES (
  $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12
) RETURNING *;

-- name: GetExportProject :one
SELECT * FROM export_projects
WHERE id = $1 LIMIT 1;

-- name: UpdateExportProject :one
UPDATE export_projects
SET
  step = $2,
  updated_at = now()
WHERE
    id = $1
RETURNING *;

-- name: ListExportProjects :many
SELECT * FROM export_projects
WHERE
  (sqlc.narg(title) IS NULL OR title ILIKE '%' || sqlc.narg(title) || '%')
  AND (sqlc.narg(step) IS NULL OR step = sqlc.narg(step))
  AND (sqlc.narg(created_at_start) IS NULL OR created_at >= sqlc.narg(created_at_start))
  AND (sqlc.narg(created_at_end) IS NULL OR created_at <= sqlc.narg(created_at_end))
  AND (sqlc.narg(updated_at_start) IS NULL OR updated_at >= sqlc.narg(updated_at_start))
  AND (sqlc.narg(updated_at_end) IS NULL OR updated_at <= sqlc.narg(updated_at_end))
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

-- name: DeleteExportProject :exec
DELETE FROM export_projects
WHERE id = $1;

-- name: DeleteExportProjectProducts :exec
DELETE FROM export_project_products
WHERE project_id = $1;

-- name: GetExportProjectProducts :many
SELECT products.*, export_project_products.error  from products
JOIN export_project_products ON products.id = export_project_products.product_id
WHERE export_project_products.project_id = $1;

-- name: GetExportProjectProductIds :many
SELECT product_id from export_project_products
WHERE project_id = $1;

-- name: CreateExportProjectProduct :one
INSERT INTO export_project_products (
  project_id,
  product_id
) VALUES (
  $1, $2
) RETURNING *;

-- name: UpdateExportProjectProduct :one
UPDATE export_project_products SET
  error = $3
WHERE
  project_id = $1 AND product_id = $2
RETURNING *;
