-- name: CreateSubscription :one
INSERT INTO subscriptions (
  client_id,
  tier,
  product_count,
  interval,
  price,
  start_date,
  end_date,
  status
) VALUES (
  $1, $2, $3, $4, $5, $6, $7, $8
) RETURNING *;

-- name: GetSubscription :one
SELECT * FROM subscriptions
WHERE id = $1 LIMIT 1;

-- name: ListSubscriptions :many
SELECT * FROM subscriptions
WHERE client_id = $1;

-- name: UpdateSubscription :one
UPDATE subscriptions
SET
  tier = $2,
  product_count = $3,
  interval = $4,
  price = $5,
  start_date = $6,
  end_date = $7,
  status = $8
WHERE id = $1
RETURNING *;
