-- name: CreateAsset :one
INSERT INTO assets (
  product_id,
  client_id,
  is_private,
  path,
  url,
  alternate,
  mime_type,
  error
) VALUES (
  $1, $2, $3, $4, $5, $6, $7, $8
) RETURNING *;

-- name: UpdateAsset :one
UPDATE assets
SET
  product_id = $2,
  is_private = $3,
  path = $4,
  url = $5,
  alternate = $6,
  mime_type = $7,
  error = $8,
  updated_at = now()
WHERE
  id = $1
RETURNING *;

-- name: ListProductAssets :many
SELECT * FROM assets
WHERE assets.product_id = $1;

-- name: ListClientAssets :many
SELECT * FROM assets
WHERE assets.client_id = $1
ORDER BY created_at DESC;

-- name: DeleteAsset :exec
DELETE FROM assets
WHERE id = $1;
