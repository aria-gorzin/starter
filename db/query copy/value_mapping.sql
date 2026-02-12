-- name: CreateValueMapping :one
INSERT INTO value_mappings (
  title,
  attribute_id,
  client_id
) VALUES (
  $1, $2, $3
) RETURNING *;

-- name: GetValueMapping :one
SELECT * FROM value_mappings
WHERE id = $1 LIMIT 1;

-- name: UpdateValueMapping :one
UPDATE value_mappings SET
  status = $2,
  updated_at = now()
WHERE id = $1
RETURNING *;

-- name: ListValueMappings :many
SELECT * FROM value_mappings
WHERE client_id IS NULL OR client_id = sqlc.arg(client_id);

-- name: DeleteValueMapping :exec
DELETE FROM value_mappings
WHERE id = $1;

-- name: CreateValueMappingItem :one
INSERT INTO value_mapping_items (
  value_mapping_id,
  target_value,
  original_values
) VALUES (
  $1, $2, $3
) RETURNING *;

-- name: UpdateValueMappingItem :one
UPDATE value_mapping_items SET
  original_values = $3
WHERE value_mapping_id = $1 AND target_value = $2
RETURNING *;

-- name: GetValueMappingItems :many
SELECT *
FROM value_mapping_items
WHERE value_mapping_id = $1;

-- name: DeleteValueMappingItem :exec
DELETE FROM value_mapping_items
WHERE target_value = $1 AND value_mapping_id = $2;
