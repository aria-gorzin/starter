-- name: CreateUser :one
INSERT INTO users (
  full_name,
  email,
  password,
  is_admin,
  phone,
  client_id,
  status
) VALUES (
  $1, $2, $3, $4, $5, $6, $7
) RETURNING *;

-- name: GetUser :one
SELECT * FROM users
WHERE id = $1 LIMIT 1;

-- name: GetUserByEmail :one
SELECT * FROM users
WHERE email = $1 LIMIT 1;

-- name: UpdateUser :one
UPDATE users
SET
  full_name = $2,
  is_admin = $3,
  phone = $4,
  status = $5,
  updated_at = now()
WHERE
  id = $1
RETURNING *;

-- name: SetTowFactor :one
UPDATE users
SET
  two_factor_secret = $2,
  two_factor_enabled = $3
WHERE
  id = $1
RETURNING *;

-- name: ListClientUsers :many
SELECT * FROM users
WHERE client_id = $1 AND status != 'deleted';

-- name: VerifyEmail :one
UPDATE users
SET
  is_email_verified = true
WHERE
  email = $1
RETURNING *;

-- name: VerifyPhone :one
UPDATE users
SET
  is_phone_verified = true
WHERE
  phone = $1
RETURNING *;

-- name: UpdateUserPassword :one
UPDATE users
SET
  password = $2
WHERE
  id = $1
RETURNING *;

-- name: DeleteUser :exec
UPDATE users
SET
  status = 'deleted'
WHERE
  id = $1;

-- name: ListUsers :many
SELECT * FROM users
WHERE
  (sqlc.narg(full_name)::text IS NULL OR full_name ILIKE '%' || sqlc.narg(full_name)::text || '%')
  AND (sqlc.narg(email)::text IS NULL OR email ILIKE '%' || sqlc.narg(email)::text || '%')
  AND (sqlc.narg(phone)::text IS NULL OR phone ILIKE '%' || sqlc.narg(phone)::text || '%')
  AND (sqlc.narg(is_admin)::boolean IS NULL OR is_admin = sqlc.narg(is_admin)::boolean)
  AND (sqlc.narg(status)::text IS NULL OR status = sqlc.narg(status)::text)
  AND (sqlc.narg(client_id)::bigint IS NULL OR client_id = sqlc.narg(client_id)::bigint)
  AND (sqlc.narg(created_at_start)::timestamptz IS NULL OR created_at >= sqlc.narg(created_at_start)::timestamptz)
  AND (sqlc.narg(created_at_end)::timestamptz IS NULL OR created_at <= sqlc.narg(created_at_end)::timestamptz)
  AND (sqlc.narg(updated_at_start)::timestamptz IS NULL OR updated_at >= sqlc.narg(updated_at_start)::timestamptz)
  AND (sqlc.narg(updated_at_end)::timestamptz IS NULL OR updated_at <= sqlc.narg(updated_at_end)::timestamptz)
ORDER BY
  CASE
    WHEN sqlc.narg(sort)::text = 'email' AND sqlc.narg(sort_direction)::text = 'asc' THEN email
  END ASC,
  CASE
    WHEN sqlc.narg(sort)::text = 'email' THEN email
  END DESC,
  CASE
    WHEN sqlc.narg(sort)::text = 'full_name' AND sqlc.narg(sort_direction)::text = 'asc' THEN full_name
  END ASC,
  CASE
    WHEN sqlc.narg(sort)::text = 'full_name' THEN full_name
  END DESC,
  CASE
    WHEN sqlc.narg(sort)::text = 'created_at' AND sqlc.narg(sort_direction)::text = 'asc' THEN created_at
  END ASC,
  CASE
    WHEN sqlc.narg(sort)::text = 'created_at' THEN created_at
  END DESC,
  id ASC
LIMIT sqlc.arg(per_page) OFFSET sqlc.arg(skip);

-- name: CountUsers :one
SELECT COUNT(id) FROM users
WHERE
  (sqlc.narg(full_name)::text IS NULL OR full_name ILIKE '%' || sqlc.narg(full_name)::text || '%')
  AND (sqlc.narg(email)::text IS NULL OR email ILIKE '%' || sqlc.narg(email)::text || '%')
  AND (sqlc.narg(phone)::text IS NULL OR phone ILIKE '%' || sqlc.narg(phone)::text || '%')
  AND (sqlc.narg(is_admin)::boolean IS NULL OR is_admin = sqlc.narg(is_admin)::boolean)
  AND (sqlc.narg(status)::text IS NULL OR status = sqlc.narg(status)::text)
  AND (sqlc.narg(client_id)::bigint IS NULL OR client_id = sqlc.narg(client_id)::bigint)
  AND (sqlc.narg(created_at_start)::timestamptz IS NULL OR created_at >= sqlc.narg(created_at_start)::timestamptz)
  AND (sqlc.narg(created_at_end)::timestamptz IS NULL OR created_at <= sqlc.narg(created_at_end)::timestamptz)
  AND (sqlc.narg(updated_at_start)::timestamptz IS NULL OR updated_at >= sqlc.narg(updated_at_start)::timestamptz)
  AND (sqlc.narg(updated_at_end)::timestamptz IS NULL OR updated_at <= sqlc.narg(updated_at_end)::timestamptz);