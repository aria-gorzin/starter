-- name: CreateExportTemplate :one
INSERT INTO export_templates (
  title,
  category_id,
  client_id,
  status
) VALUES (
  $1, $2, $3, $4
) RETURNING *;

-- name: GetExportTemplate :one
SELECT * FROM export_templates
WHERE id = $1 LIMIT 1;

-- name: UpdateExportTemplate :one
UPDATE export_templates SET
  title = $2,
  status = $3,
  updated_at = now()
WHERE id = $1
RETURNING *;

-- name: ListExportTemplates :many
SELECT * FROM export_templates
WHERE client_id IS NULL OR client_id = $1;

-- name: DeleteExportTemplate :exec
DELETE FROM export_templates
WHERE id = $1;

-- name: CreateExportTemplateAttribute :one
INSERT INTO export_template_attributes (
  attribute_id,
  template_id,
  target,
  unit,
  delimiter,
  default_value,
  view_order,
  is_required,
  header_color,
  body_color
) VALUES (
  $1, $2, $3, $4, $5, $6, $7, $8, $9, $10
) RETURNING *;

-- name: UpdateExportTemplateAttribute :one
UPDATE export_template_attributes SET
  target         = $3,
  unit           = $4,
  delimiter      = $5,
  default_value  = $6,
  view_order     = $7,
  is_required    = $8,
  header_color   = $9,
  body_color     = $10,
  updated_at     = now()
WHERE attribute_id = $1 AND template_id = $2
RETURNING *;

-- name: ListExportTemplateAttributes :many
SELECT export_template_attributes.*, attributes.*
FROM export_template_attributes JOIN attributes ON export_template_attributes.attribute_id = attributes.id
WHERE template_id = $1;

-- name: DeleteExportTemplateAttribute :exec
DELETE FROM export_template_attributes
WHERE template_id = $1 AND attribute_id = $2;
