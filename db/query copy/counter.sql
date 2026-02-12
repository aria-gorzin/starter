-- name: GetCounter :one
SELECT * FROM counter
WHERE key = $1;

-- name: IncrementCounter :one
UPDATE counter SET
  count = count + 1
WHERE key = $1
RETURNING *;


-- name: UpsertCounter :one
INSERT INTO counter (key, count)
VALUES ($1, $2)
ON CONFLICT (key) DO UPDATE
SET count = counter.count + EXCLUDED.count
RETURNING *;

-- name: IncrementCounterUpsert :one
INSERT INTO counter (key)
VALUES ($1, 1)
ON CONFLICT (key) DO UPDATE
SET count = counter.count + 1
RETURNING *;