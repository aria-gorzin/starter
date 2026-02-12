

-- name: GetUser :one
SELECT * FROM "user"
WHERE email = $1 LIMIT 1;
