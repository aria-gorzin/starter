-- name: CreateSession :one
INSERT INTO sessions (
  email,
  refresh_token,
  user_agent,
  user_ip,
  is_blocked,
  expires_at
) VALUES (
  $1, $2, $3, $4, $5, $6
) RETURNING *;

-- name: GetSession :one
SELECT * FROM sessions
WHERE refresh_token = $1 LIMIT 1;
