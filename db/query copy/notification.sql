-- name: CreateNotification :one
INSERT INTO notifications (
  client_id,
  title,
  message,
  type,
  project_id,
  project_type
) VALUES (
  $1, $2, $3, $4, $5, $6
) RETURNING *;

-- name: GetNotification :one
SELECT * FROM notifications
WHERE id = $1 LIMIT 1;

-- name: ListNotifications :many
SELECT * FROM notifications
WHERE client_id = $1
ORDER BY created_at DESC
LIMIT $2 OFFSET $3;

-- name: UpdateNotification :one
UPDATE notifications SET
  is_read = $2,
  is_seen = $3,
  updated_at = now()
WHERE
  id = $1
RETURNING *;
