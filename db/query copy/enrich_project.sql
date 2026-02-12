-- name: CreateEnrichProject :one
INSERT INTO enrich_projects (
  title,
  category_id,
  client_id,
  filters,
  attribute_id,
  value,
  params,
  step,
  project_type
) VALUES (
  $1, $2, $3, $4, $5, $6, $7, $8, $9
) RETURNING *;

-- name: GetEnrichProject :one
SELECT * FROM enrich_projects
WHERE id = $1 LIMIT 1;

-- name: UpdateEnrichProject :one
UPDATE enrich_projects
SET
  step = $2,
  updated_at = now()
WHERE
    id = $1
RETURNING *;

-- name: ListEnrichProjects :many
SELECT * FROM enrich_projects
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

-- name: DeleteEnrichProject :exec
DELETE FROM enrich_projects
WHERE id = $1;

-- name: GetEnrichProjectProducts :many
SELECT products.*, enrich_project_products.error  from products
JOIN enrich_project_products ON products.id = enrich_project_products.product_id
WHERE enrich_project_products.project_id = $1
LIMIT $2 OFFSET $3;

-- name: GetEnrichProjectProductIds :many
SELECT product_id from enrich_project_products
WHERE project_id = $1;

-- name: CreateEnrichProjectProduct :one
INSERT INTO enrich_project_products (
  project_id,
  product_id
) VALUES (
  $1, $2
) RETURNING *;

-- name: UpdateEnrichProjectProduct :one
UPDATE enrich_project_products
SET
  error = $3
WHERE
    project_id = $1
    AND product_id = $2
RETURNING *;

-- name: DeleteEnrichProjectProducts :exec
DELETE FROM enrich_project_products
WHERE project_id = $1;
