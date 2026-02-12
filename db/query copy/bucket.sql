-- name: CreateBucket :one
INSERT INTO buckets (
  client_id,
  category_id,
  title,
  type,
  filters,
  sort,
  status
) VALUES (
  $1, $2, $3, $4, $5, $6, $7
) RETURNING *;

-- name: GetBucket :one
SELECT * FROM buckets
WHERE id = $1 LIMIT 1;

-- name: UpdateBucket :one
UPDATE buckets
SET
  title = $2,
  type = $3,
  filters = $4,
  sort = $5,
  status = $6,
  updated_at = now()
WHERE
  id = $1
RETURNING *;

-- name: ListBuckets :many
SELECT * FROM buckets
WHERE
  (sqlc.narg(title)::text IS NULL OR title ILIKE '%' || sqlc.narg(title)::text || '%')
  AND (sqlc.narg(type)::text IS NULL OR type ILIKE '%' || sqlc.narg(type)::text || '%')
  AND (sqlc.narg(status)::text IS NULL OR status = sqlc.narg(status)::text)
  AND (sqlc.narg(created_at_start)::timestamptz IS NULL OR created_at >= sqlc.narg(created_at_start)::timestamptz)
  AND (sqlc.narg(created_at_end)::timestamptz IS NULL OR created_at <= sqlc.narg(created_at_end)::timestamptz)
  AND (sqlc.narg(updated_at_start)::timestamptz IS NULL OR updated_at >= sqlc.narg(updated_at_start)::timestamptz)
  AND (sqlc.narg(updated_at_end)::timestamptz IS NULL OR updated_at <= sqlc.narg(updated_at_end)::timestamptz)
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

-- name: CountBuckets :one
SELECT COUNT(id) FROM buckets
WHERE
  (sqlc.narg(title)::text IS NULL OR title ILIKE '%' || sqlc.narg(title)::text || '%')
  AND (sqlc.narg(type)::text IS NULL OR type ILIKE '%' || sqlc.narg(type)::text || '%')
  AND (sqlc.narg(status)::text IS NULL OR status = sqlc.narg(status)::text)
  AND (sqlc.narg(created_at_start)::timestamptz IS NULL OR created_at >= sqlc.narg(created_at_start)::timestamptz)
  AND (sqlc.narg(created_at_end)::timestamptz IS NULL OR created_at <= sqlc.narg(created_at_end)::timestamptz)
  AND (sqlc.narg(updated_at_start)::timestamptz IS NULL OR updated_at >= sqlc.narg(updated_at_start)::timestamptz)
  AND (sqlc.narg(updated_at_end)::timestamptz IS NULL OR updated_at <= sqlc.narg(updated_at_end)::timestamptz);

-- name: DeleteBucket :exec
DELETE FROM buckets
WHERE id = $1;

-- name: CreateBucketProduct :one
INSERT INTO bucket_products (
  product_id,
  bucket_id
) VALUES (
  $1, $2
) RETURNING *;

-- name: DeleteBucketProduct :exec
DELETE FROM bucket_products
WHERE product_id = $1 AND bucket_id = $2;

-- name: ListBucketProducts :many
SELECT * from products JOIN bucket_products ON products.id = bucket_products.product_id
WHERE bucket_products.bucket_id = $1;

-- name: GetBucketProductIds :many
SELECT product_id from bucket_products
WHERE bucket_id = $1;
