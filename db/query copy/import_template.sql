-- name: CreateImportTemplate :one
INSERT INTO import_templates (
  title,
  category_id,
  client_id,
  status
) VALUES (
  $1, $2, $3, $4
) RETURNING *;

-- name: GetImportTemplate :one
SELECT * FROM import_templates
WHERE id = $1 LIMIT 1;

-- name: UpdateImportTemplate :one
UPDATE import_templates SET
  title = $2,
  status = $3,
  updated_at = now()
WHERE
  id = $1
RETURNING *;

-- name: ListImportTemplates :many
SELECT * FROM import_templates
WHERE client_id IS NULL OR client_id = $1;

-- name: DeleteImportTemplate :exec
DELETE FROM import_templates
WHERE id = $1;

-- name: CreateImportTemplateAttribute :one
INSERT INTO import_template_attributes (
  attribute_id,
  template_id,
  source,
  unit,
  delimiter,
  default_value
) VALUES (
  $1, $2, $3, $4, $5, $6
) RETURNING *;

-- name: GetImportTemplateAttribute :one
SELECT * FROM import_template_attributes
WHERE template_id = $1 AND attribute_id = $2 LIMIT 1;

-- name: UpdateImportTemplateAttribute :one
UPDATE import_template_attributes SET
  source         = $3,
  unit           = $4,
  delimiter      = $5,
  default_value  = $6,
  updated_at     = now()
WHERE template_id = $1 AND attribute_id = $2
RETURNING *;

-- name: ListImportTemplateAttributes :many
SELECT import_template_attributes.*, attributes.*
FROM import_template_attributes JOIN attributes ON import_template_attributes.attribute_id = attributes.id
WHERE template_id = $1;

-- name: DeleteImportTemplateAttribute :exec
DELETE FROM import_template_attributes
WHERE template_id = $1 AND attribute_id = $2;
