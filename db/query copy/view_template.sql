-- name: CreateViewTemplate :one
INSERT INTO view_templates (
  title,
  category_id,
  client_id
) VALUES (
  $1, $2, $3
) RETURNING *;

-- name: GetViewTemplate :one
SELECT * FROM view_templates
WHERE id = $1 LIMIT 1;

-- name: UpdateViewTemplate :one
UPDATE view_templates SET
  title = $2,
  updated_at = now()
WHERE id = $1
RETURNING *;

-- name: ListViewTemplates :many
SELECT * FROM view_templates
WHERE client_id IS NULL OR client_id = $1;

-- name: DeleteViewTemplate :exec
DELETE FROM view_templates
WHERE id = $1;

-- name: CreateViewTemplateAttribute :one
INSERT INTO view_template_attributes (
  attribute_id,
  template_id,
  target,
  default_value,
  view_order,
  show,
  unit,
  is_on_card,
  is_on_filter,
  is_on_list,
  is_on_detail
) VALUES (
  $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11
) RETURNING *;

-- name: GetViewTemplateAttributes :many
SELECT view_template_attributes.*, attributes.*
FROM view_template_attributes JOIN attributes ON view_template_attributes.attribute_id = attributes.id
WHERE template_id = $1;

-- name: DeleteViewTemplateAttribute :exec
DELETE FROM view_template_attributes
WHERE attribute_id = $1 AND template_id = $2;
