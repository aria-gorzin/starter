-- name: CreateCategory :one
INSERT INTO categories (
  title,
  description,
  code_length,
  parent_id,
  grouping_function_id,
  identification_attribute_id,
  status
) VALUES (
  $1, $2, $3, $4, $5, $6, $7
) RETURNING *;

-- name: GetCategory :one
SELECT * FROM categories
WHERE id = $1 LIMIT 1;

-- name: UpdateCategory :one
UPDATE categories
SET
  title = $2,
  description = $3,
  code_length = $4,
  parent_id = $5,
  grouping_function_id = $6,
  identification_attribute_id = $7,
  status = $8,
  updated_at = now()
WHERE
  id = $1
RETURNING *;

-- name: ListCategories :many
SELECT * FROM categories;

-- name: GetCategoriesByIds :many
SELECT * FROM categories
WHERE id = ANY($1);
  
-- name: DeleteCategory :exec
DELETE FROM categories
WHERE id = $1;

-- name: CreateCategoryAttribute :exec
INSERT INTO category_attributes (
  category_id,
  attribute_id,
  client_id,
  default_unit,
  filter_component,
  view_order,
  is_required,
  is_unique,
  is_searchable,
  is_editable,
  is_main_attribute,
  is_exportable,
  is_viewable
) VALUES (
  $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13
) RETURNING *;

-- name: GetCategoryAttribute :one
SELECT attribute.*, category_attributes.* FROM category_attributes
JOIN attributes as attribute ON attribute.id = category_attributes.attribute_id
WHERE category_attributes.category_id = $1 AND category_attributes.attribute_id = $2;

-- name: UpdateCategoryAttribute :exec
UPDATE category_attributes
SET
  attribute_id = $3,
  default_unit = $4,
  filter_component = $5,
  view_order = $6,
  is_viewable = $7,
  is_exportable = $8,
  is_required = $9,
  is_unique = $10,
  is_searchable = $11,
  is_editable = $12,
  is_main_attribute = $13,
  updated_at = now()
WHERE
  category_id = $1 AND attribute_id = $2
RETURNING *;

-- name: ListCategoryAttributes :many
SELECT attribute.title as attribute_title, category_attributes.* FROM category_attributes
JOIN attributes as attribute ON attribute.id = category_attributes.attribute_id
WHERE category_id = $1;

-- name: DeleteCategoryAttribute :exec
DELETE FROM category_attributes
WHERE category_id = $1 AND attribute_id = $2;
