-- name: CreatePayment :one
INSERT INTO payments (
  client_id,
  subscription_id,
  amount,
  payment_date,
  refrence_token,
  status
) VALUES (
  $1, $2, $3, $4, $5, $6
) RETURNING *;

-- name: GetPayment :one
SELECT * FROM payments
WHERE id = $1 LIMIT 1;

-- name: ListPayments :many
SELECT * FROM payments
WHERE client_id = $1;

-- name: UpdatePayment :one
UPDATE payments
SET
  client_id = $2,
  subscription_id = $3,
  amount = $4,
  payment_date = $5,
  refrence_token = $6,
  status = $7
WHERE id = $1
RETURNING *;
