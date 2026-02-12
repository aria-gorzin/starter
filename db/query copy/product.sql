-- name: CreateProduct :one
INSERT INTO products (
  category_id,
  client_id,
  blob_id
) VALUES (
  $1, $2, $3
) RETURNING *;

-- name: GetProduct :one
SELECT * FROM products
WHERE id = $1 LIMIT 1;

-- name: UpdateProduct :one
UPDATE products SET
  category_id = $2,
  client_id = $3
WHERE id = $1
RETURNING *;

-- name: ListProducts :many
SELECT * FROM products
WHERE client_id = sqlc.arg(client_id)
    AND is_deleted = false
    AND sqlc.narg(category_id) IS NULL OR category_id = sqlc.narg(category_id)
ORDER BY created_at DESC
LIMIT sqlc.arg(per_page) OFFSET sqlc.arg(skip);

-- name: DeleteProduct :exec
DELETE FROM products
WHERE id = $1;
