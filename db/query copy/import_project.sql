-- name: CreateImportProject :one
INSERT INTO import_projects (
  title,
  category_id,
  client_id,
  template_id,
  channel_id,
  delimiter,
  total_count,
  processed_count,
  error_count,
  ignored_count,
  duplicate_count,
  new_action,
  existing_action,
  step
) VALUES (
  $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14
) RETURNING *;

-- name: GetImportProject :one
SELECT * FROM import_projects
WHERE id = $1 LIMIT 1;

-- name: UpdateImportProject :one
UPDATE import_projects
SET
  step = $2,
  updated_at = now()
WHERE
    id = $1
RETURNING *;

-- name: ListImportProjects :many
SELECT * FROM import_projects
WHERE client_id IS NULL OR client_id = $1;


-- name: DeleteImportProject :exec
DELETE FROM import_projects
WHERE id = $1;

-- name: DeleteImportProjectProducts :exec
DELETE FROM import_project_products
WHERE project_id = $1;

-- name: CreateImportProjectProduct :one
INSERT INTO import_project_products (
  project_id,
  product_id
) VALUES (
  $1, $2
) RETURNING *;

-- name: GetImportProjectProducts :many
SELECT products.*, import_project_products.error from products
JOIN import_project_products ON products.id = import_project_products.product_id
WHERE import_project_products.project_id = $1 LIMIT $2 OFFSET $3;

-- name: UpdateImportProjectProduct :one
UPDATE import_project_products
SET
  error = $3
WHERE
    project_id = $1 AND product_id = $2
RETURNING *;
