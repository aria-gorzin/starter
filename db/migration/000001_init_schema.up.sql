-- SQL dump generated using DBML (dbml.dbdiagram.io)
-- Database: PostgreSQL
-- Generated at: 2026-02-06T06:59:33.475Z

CREATE EXTENSION postgis;
CREATE TABLE "cylinder" (
  "id" bigserial PRIMARY KEY NOT NULL,
  "gas_type" int,
  "title" varchar(255) NOT NULL,
  "short_title" varchar(255),
  "detection_title" varchar(255) NOT NULL,
  "illegal_above_row" integer,
  "image" varchar(255),
  "client_id" bigint NOT NULL,
  "capacity" numeric NOT NULL,
  "display_capacity" varchar(255),
  "contract_required" bool DEFAULT false,
  "created_at" timestamp NOT NULL,
  "updated_at" timestamp NOT NULL
);

CREATE TABLE "external_cylinder" (
  "cylinder_id" bigint PRIMARY KEY NOT NULL,
  "external_id" varchar(255) NOT NULL,
  "empty_cylinder_id" varchar(255),
  "gas_id" varchar(255),
  "title" varchar(255),
  "cylinder_title" varchar(255),
  "gas_title" varchar(255),
  "created_at" timestamp NOT NULL,
  "updated_at" timestamp NOT NULL
);

CREATE TABLE "chamber" (
  "id" bigserial PRIMARY KEY NOT NULL,
  "door_number" int,
  "row" int,
  "column" int,
  "side" int,
  "machine_id" bigint NOT NULL,
  "is_full" bool DEFAULT false,
  "cylinder_id" bigint,
  "is_cylinder_full" bool NOT NULL,
  "is_active" bool DEFAULT true,
  "created_at" timestamp NOT NULL,
  "updated_at" timestamp NOT NULL
);

CREATE TABLE "chamber_history" (
  "id" bigserial PRIMARY KEY NOT NULL,
  "chamber_id" bigint NOT NULL,
  "load_id" bigint,
  "order_id" bigint,
  "user_id" bigint,
  "is_full" bool NOT NULL,
  "cylinder_id" bigint,
  "is_cylinder_full" bool NOT NULL,
  "event" int,
  "created_at" timestamp NOT NULL
);

CREATE TABLE "client" (
  "id" bigserial PRIMARY KEY NOT NULL,
  "parent_id" bigint,
  "title" varchar(255) NOT NULL,
  "full_title" varchar(255),
  "fleet_id" varchar(255) UNIQUE NOT NULL,
  "is_active" bool DEFAULT true,
  "created_at" timestamp NOT NULL,
  "updated_at" timestamp NOT NULL
);

CREATE TABLE "api_key" (
  "id" bigserial PRIMARY KEY NOT NULL,
  "api_key" varchar(255) UNIQUE NOT NULL,
  "client_id" bigint,
  "user_group_id" bigint,
  "created_at" timestamp NOT NULL,
  "updated_at" timestamp NOT NULL
);

CREATE TABLE "counter" (
  "id" integer PRIMARY KEY NOT NULL,
  "type" varchar(255) NOT NULL,
  "count" integer NOT NULL
);

CREATE TABLE "credit" (
  "id" bigserial PRIMARY KEY NOT NULL,
  "original_order_id" bigint,
  "order_id" bigint,
  "client_id" bigint NOT NULL,
  "is_valid" bool NOT NULL DEFAULT true,
  "amount" numeric NOT NULL,
  "user_id" bigint,
  "code" varchar(50) NOT NULL,
  "expiry_date" timestamp,
  "note" varchar(255),
  "machine_id" bigint,
  "cylinder_id" bigint,
  "creator_id" bigint,
  "created_at" timestamp NOT NULL,
  "updated_at" timestamp NOT NULL
);

CREATE TABLE "credit_usage" (
  "id" bigserial PRIMARY KEY NOT NULL,
  "credit_id" bigint NOT NULL,
  "order_id" bigint NOT NULL,
  "amount" numeric NOT NULL,
  "created_at" timestamp NOT NULL,
  "updated_at" timestamp NOT NULL
);

CREATE TABLE "currency_rate" (
  "currency" varchar(10) PRIMARY KEY NOT NULL,
  "rate" numeric,
  "created_at" timestamp NOT NULL,
  "updated_at" timestamp NOT NULL
);

CREATE TABLE "detection_attempt" (
  "id" bigserial PRIMARY KEY NOT NULL,
  "order_id" bigint NOT NULL,
  "cylinder_id" bigint,
  "image" varchar(255),
  "detected_identifier" varchar(255),
  "confidence" numeric NOT NULL,
  "created_at" timestamp NOT NULL,
  "updated_at" timestamp NOT NULL
);

CREATE TABLE "load" (
  "id" bigserial PRIMARY KEY NOT NULL,
  "machine_id" bigint NOT NULL,
  "user_id" bigint,
  "fill_order_id" bigint,
  "created_at" timestamp NOT NULL,
  "updated_at" timestamp NOT NULL
);

CREATE TABLE "fill_order" (
  "id" bigserial PRIMARY KEY NOT NULL,
  "created_by_id" bigint NOT NULL,
  "assigned_to_id" bigint NOT NULL,
  "truck_id" bigint NOT NULL,
  "notes" text,
  "travel_document" text,
  "status" int NOT NULL DEFAULT 0,
  "created_at" timestamp NOT NULL,
  "updated_at" timestamp NOT NULL
);

CREATE TABLE "truck" (
  "id" bigserial PRIMARY KEY NOT NULL,
  "name" varchar(100) NOT NULL,
  "capacity" integer NOT NULL,
  "created_at" timestamp NOT NULL,
  "updated_at" timestamp NOT NULL
);

CREATE TABLE "truck_location" (
  "id" bigserial PRIMARY KEY NOT NULL,
  "fill_order_id" bigint,
  "truck_id" bigint NOT NULL,
  "point" geometry(Point,4326) NOT NULL,
  "created_at" timestamp NOT NULL
);

CREATE TABLE "fill_order_cylinder" (
  "id" bigserial PRIMARY KEY NOT NULL,
  "fill_order_id" bigint NOT NULL,
  "cylinder_id" bigint NOT NULL,
  "machine_id" bigint NOT NULL,
  "count" integer NOT NULL,
  "created_at" timestamp NOT NULL,
  "updated_at" timestamp NOT NULL
);

CREATE TABLE "fix_order" (
  "id" bigserial PRIMARY KEY NOT NULL,
  "created_by_id" bigint NOT NULL,
  "assigned_to_id" bigint,
  "machine_id" bigint NOT NULL,
  "status" int NOT NULL DEFAULT 0,
  "notes" text,
  "issue" varchar(255) NOT NULL,
  "action" text,
  "documents" varchar(255),
  "created_at" timestamp NOT NULL,
  "updated_at" timestamp NOT NULL
);

CREATE TABLE "machine" (
  "id" bigserial PRIMARY KEY NOT NULL,
  "client_id" bigint NOT NULL,
  "api_key" varchar(255) UNIQUE NOT NULL,
  "title" varchar(100) NOT NULL,
  "number" int UNIQUE,
  "url" varchar(255) UNIQUE,
  "group_id" bigint,
  "management_id" varchar(50) UNIQUE,
  "type" int NOT NULL,
  "layout_id" int NOT NULL DEFAULT 0,
  "terminal_id" varchar(255),
  "secret" varchar(255),
  "needs_attention" bool DEFAULT false,
  "is_active" bool DEFAULT true,
  "created_at" timestamp NOT NULL,
  "updated_at" timestamp NOT NULL
);

CREATE TABLE "machine_address" (
  "id" bigserial PRIMARY KEY NOT NULL,
  "machine_id" bigint NOT NULL,
  "address" text,
  "region" varchar(255),
  "point" geometry(Point,4326) NOT NULL,
  "created_at" timestamp NOT NULL,
  "updated_at" timestamp NOT NULL
);

CREATE TABLE "machine_lock" (
  "id" bigserial PRIMARY KEY NOT NULL,
  "machine_id" bigint NOT NULL,
  "user_id" bigint NOT NULL,
  "locked" bool NOT NULL,
  "lock_message" text,
  "lock_reason" text,
  "created_at" timestamp NOT NULL,
  "updated_at" timestamp NOT NULL
);

CREATE TABLE "machine_note" (
  "id" bigserial PRIMARY KEY NOT NULL,
  "machine_id" bigint NOT NULL,
  "user_id" bigint NOT NULL,
  "note" text,
  "is_public" bool NOT NULL DEFAULT false,
  "created_at" timestamp NOT NULL,
  "updated_at" timestamp NOT NULL
);

CREATE TABLE "external_machine" (
  "machine_id" bigint PRIMARY KEY NOT NULL,
  "external_id" varchar(255),
  "title" varchar(255),
  "terminal_id" varchar(255),
  "store_number" varchar(255),
  "created_at" timestamp NOT NULL,
  "updated_at" timestamp NOT NULL
);

CREATE TABLE "machine_cylinder" (
  "id" bigserial PRIMARY KEY NOT NULL,
  "cylinder_id" bigint NOT NULL,
  "machine_group_id" bigint NOT NULL,
  "min" integer NOT NULL,
  "target" integer,
  "order" integer NOT NULL,
  "missing_cap_penalty" numeric NOT NULL DEFAULT 0,
  "missing_valve_penalty" numeric NOT NULL DEFAULT 0,
  "missing_label_penalty" numeric NOT NULL DEFAULT 0,
  "created_at" timestamp NOT NULL,
  "updated_at" timestamp NOT NULL
);

CREATE TABLE "machine_group" (
  "id" bigserial PRIMARY KEY NOT NULL,
  "client_id" bigint NOT NULL,
  "title" varchar(255) NOT NULL,
  "created_at" timestamp NOT NULL,
  "updated_at" timestamp NOT NULL
);

CREATE TABLE "machine_group_history" (
  "id" bigserial PRIMARY KEY NOT NULL,
  "machine_id" bigint NOT NULL,
  "group_id" bigint,
  "user_id" bigint NOT NULL,
  "created_at" timestamp NOT NULL
);

CREATE TABLE "machine_status" (
  "id" bigserial PRIMARY KEY NOT NULL,
  "machine_id" bigint NOT NULL,
  "maintainer_id" bigint,
  "status" int NOT NULL DEFAULT 0,
  "door_status" json,
  "gas_sensor_status" json,
  "fan_status" json,
  "printer_status" json,
  "payment_terminal_status" json,
  "carousel_status" json,
  "camera_status" json,
  "error" text,
  "last_status_change" timestamp NOT NULL,
  "order_id" bigint,
  "load_id" bigint,
  "last_event" text,
  "component" varchar(50),
  "locked" bool DEFAULT false,
  "reboot_lock" bool DEFAULT false,
  "has_critical_error" bool DEFAULT false
);

CREATE TABLE "machine_user" (
  "id" bigserial PRIMARY KEY NOT NULL,
  "user_group_id" bigint NOT NULL,
  "machine_id" bigint,
  "created_at" timestamp NOT NULL
);

CREATE TABLE "notification" (
  "id" bigserial PRIMARY KEY NOT NULL,
  "client_id" bigint NOT NULL,
  "machine_id" bigint,
  "title" varchar(255) NOT NULL,
  "notification_type_id" bigint NOT NULL,
  "level" int NOT NULL DEFAULT 0,
  "content" text NOT NULL,
  "read" bool DEFAULT false,
  "seen" bool DEFAULT false,
  "metadata" json NOT NULL,
  "created_at" timestamp NOT NULL,
  "updated_at" timestamp NOT NULL
);

CREATE TABLE "notification_template" (
  "id" bigserial PRIMARY KEY NOT NULL,
  "level" int NOT NULL,
  "title" varchar(255) NOT NULL,
  "description" text NOT NULL,
  "content" text NOT NULL,
  "created_at" timestamp NOT NULL,
  "updated_at" timestamp NOT NULL
);

CREATE TABLE "notification_type" (
  "id" bigserial PRIMARY KEY NOT NULL,
  "type" varchar(255)
);

CREATE TABLE "user_notifications" (
  "id" bigserial PRIMARY KEY NOT NULL,
  "notification_type_id" bigint NOT NULL,
  "user_id" bigint NOT NULL,
  "email" bool NOT NULL DEFAULT false,
  "sms" bool NOT NULL DEFAULT false
);

CREATE TABLE "notification_usage" (
  "id" bigserial PRIMARY KEY NOT NULL,
  "client_id" bigint NOT NULL,
  "channel" int,
  "notification_type_id" bigint NOT NULL,
  "order_id" bigint,
  "user_id" bigint,
  "machine_id" bigint,
  "created_at" timestamp NOT NULL
);

CREATE TABLE "payment" (
  "id" bigserial PRIMARY KEY NOT NULL,
  "order_id" bigint NOT NULL,
  "payment_method_id" bigint,
  "reference_token" varchar(100) NOT NULL,
  "amount" numeric NOT NULL,
  "status" int NOT NULL DEFAULT 0,
  "error" text,
  "receipt" text,
  "receipt_url" text,
  "receipt_number" varchar(100),
  "payment_intent_id" varchar(255),
  "metadata" json,
  "created_at" timestamp NOT NULL,
  "updated_at" timestamp NOT NULL
);

CREATE TABLE "refund" (
  "id" bigserial PRIMARY KEY NOT NULL,
  "payment_id" bigint NOT NULL,
  "amount" numeric NOT NULL,
  "status" int NOT NULL DEFAULT 0,
  "error" text,
  "receipt" text,
  "receipt_url" text,
  "refunded_by_id" bigint,
  "metadata" json,
  "created_at" timestamp NOT NULL,
  "updated_at" timestamp NOT NULL
);

CREATE TABLE "payment_method" (
  "id" bigserial PRIMARY KEY NOT NULL,
  "machine_id" bigint NOT NULL,
  "config_id" bigint,
  "is_active" bool DEFAULT true,
  "created_at" timestamp NOT NULL,
  "updated_at" timestamp NOT NULL
);

CREATE TABLE "payment_method_config" (
  "id" bigserial PRIMARY KEY NOT NULL,
  "client_id" bigint NOT NULL,
  "title" varchar(100) NOT NULL,
  "method" int,
  "is_cancelable" bool DEFAULT false,
  "is_auto_refundable" bool DEFAULT false,
  "refund_type" int NOT NULL DEFAULT 0,
  "refund_limit_type" int NOT NULL DEFAULT 0,
  "refund_limit_value" integer,
  "is_active" bool DEFAULT true,
  "metadata" text,
  "created_at" timestamp NOT NULL,
  "updated_at" timestamp NOT NULL
);

CREATE TABLE "permission" (
  "id" bigserial PRIMARY KEY NOT NULL,
  "title" varchar(255) UNIQUE NOT NULL,
  "description" text,
  "created_at" timestamp NOT NULL,
  "updated_at" timestamp NOT NULL
);

CREATE TABLE "user_permission" (
  "id" bigserial PRIMARY KEY NOT NULL,
  "permission_id" bigint NOT NULL,
  "user_group_id" bigint NOT NULL,
  "created_at" timestamp NOT NULL,
  "updated_at" timestamp NOT NULL
);

CREATE TABLE "schedule" (
  "id" bigserial PRIMARY KEY NOT NULL,
  "title" varchar(255),
  "created_at" timestamp NOT NULL
);

CREATE TABLE "schedule_item" (
  "id" bigserial PRIMARY KEY NOT NULL,
  "schedule_id" bigint NOT NULL,
  "start_at" timestamp NOT NULL,
  "end_at" timestamp NOT NULL,
  "updated_at" timestamp NOT NULL,
  "created_at" timestamp NOT NULL
);

CREATE TABLE "voucher" (
  "id" bigserial PRIMARY KEY NOT NULL,
  "price_id" bigint,
  "machine_group_id" bigint,
  "amount" numeric NOT NULL,
  "reason" varchar(255),
  "count" integer NOT NULL,
  "code" varchar(255),
  "can_stack" bool DEFAULT false,
  "is_active" bool DEFAULT true,
  "schedule_id" bigint,
  "created_at" timestamp NOT NULL,
  "updated_at" timestamp NOT NULL
);

CREATE TABLE "voucher_usage" (
  "id" bigserial PRIMARY KEY NOT NULL,
  "voucher_id" bigint,
  "user_id" bigint,
  "order_id" bigint,
  "redeemed" bool DEFAULT false
);

CREATE TABLE "voucher_cylinder" (
  "id" bigserial PRIMARY KEY NOT NULL,
  "voucher_id" bigint,
  "cylinder_id" bigint,
  "count" integer NOT NULL DEFAULT 1,
  "created_at" timestamp NOT NULL,
  "updated_at" timestamp NOT NULL
);

CREATE TABLE "voucher_machine_group" (
  "id" bigserial PRIMARY KEY NOT NULL,
  "voucher_id" bigint,
  "machine_group_id" bigint,
  "count" integer,
  "created_at" timestamp NOT NULL,
  "updated_at" timestamp NOT NULL
);

CREATE TABLE "voucher_payment_method" (
  "id" bigserial PRIMARY KEY NOT NULL,
  "voucher_id" bigint,
  "payment_method_id" bigint,
  "count" integer,
  "created_at" timestamp NOT NULL,
  "updated_at" timestamp NOT NULL
);

CREATE TABLE "price" (
  "id" bigserial PRIMARY KEY NOT NULL,
  "in_cylinder_id" bigint,
  "out_cylinder_id" bigint NOT NULL,
  "machine_group_id" bigint NOT NULL,
  "schedule_id" bigint,
  "amount" numeric NOT NULL,
  "is_active" bool DEFAULT true,
  "created_at" timestamp NOT NULL,
  "updated_at" timestamp NOT NULL
);

CREATE TABLE "price_history" (
  "id" bigserial PRIMARY KEY NOT NULL,
  "price_id" bigint NOT NULL,
  "amount" numeric NOT NULL,
  "is_active" bool DEFAULT true,
  "user_id" bigint,
  "created_at" timestamp NOT NULL
);

CREATE TABLE "reserve" (
  "id" bigserial PRIMARY KEY NOT NULL,
  "user_id" bigint,
  "order_id" bigint,
  "cylinder_id" bigint NOT NULL,
  "machine_id" bigint NOT NULL,
  "expires_at" timestamp,
  "used_at" timestamp,
  "created_at" timestamp NOT NULL,
  "updated_at" timestamp NOT NULL
);

CREATE TABLE "order" (
  "id" bigserial PRIMARY KEY NOT NULL,
  "machine_id" bigint NOT NULL,
  "client_id" bigint NOT NULL,
  "in_cylinder_id" bigint,
  "out_cylinder_id" bigint,
  "in_chamber_id" bigint,
  "out_chamber_id" bigint,
  "requested_price" numeric,
  "voucher_code" varchar(100),
  "abort_reason" text,
  "type" int,
  "paid" bool DEFAULT false,
  "delivered" bool DEFAULT false,
  "cylinder_returned" bool DEFAULT false,
  "status" int NOT NULL,
  "feedback_score" integer,
  "user_id" bigint,
  "credit_code" varchar(50),
  "creator_id" bigint,
  "can_exchange" bool NOT NULL,
  "in_cylinder_validated" bool DEFAULT false,
  "retry_code" varchar(50),
  "is_mobile" bool DEFAULT false,
  "price_history_id" bigint,
  "metadata" json,
  "created_at" timestamp NOT NULL,
  "updated_at" timestamp NOT NULL
);

CREATE TABLE "price_adjustment" (
  "id" bigserial PRIMARY KEY NOT NULL,
  "order_id" bigint,
  "type" varchar(255) NOT NULL,
  "value" varchar(255) NOT NULL,
  "amount" numeric NOT NULL,
  "created_at" timestamp NOT NULL,
  "updated_at" timestamp NOT NULL
);

CREATE TABLE "order_event" (
  "id" bigserial PRIMARY KEY NOT NULL,
  "order_id" bigint,
  "user_id" bigint,
  "event_type" text,
  "event_data" json,
  "need_attention" bool DEFAULT false,
  "error" text,
  "created_at" timestamp NOT NULL,
  "updated_at" timestamp NOT NULL
);

CREATE TABLE "order_note" (
  "id" bigserial PRIMARY KEY NOT NULL,
  "order_id" bigint,
  "user_id" bigint,
  "note" text NOT NULL,
  "created_at" timestamp NOT NULL,
  "updated_at" timestamp NOT NULL
);

CREATE TABLE "user" (
  "id" bigserial PRIMARY KEY NOT NULL,
  "full_name" varchar(255) NOT NULL,
  "email" varchar(255) NOT NULL,
  "email_verified" bool DEFAULT false,
  "phone" varchar(255),
  "phone_verified" bool DEFAULT false,
  "password" varchar(255) NOT NULL,
  "role" int NOT NULL,
  "two_factor_type" int,
  "totp_secret" varchar(255),
  "client_id" bigint,
  "group_id" bigint,
  "is_active" bool DEFAULT true,
  "default_pin" varchar(50),
  "created_at" timestamp NOT NULL,
  "updated_at" timestamp NOT NULL
);

CREATE TABLE "user_group" (
  "id" bigserial PRIMARY KEY NOT NULL,
  "title" varchar(255) NOT NULL,
  "client_id" bigint NOT NULL,
  "created_at" timestamp NOT NULL,
  "updated_at" timestamp NOT NULL
);

CREATE TABLE "wishlist" (
  "id" bigserial PRIMARY KEY NOT NULL,
  "user_id" bigint NOT NULL,
  "cylinder_id" bigint NOT NULL,
  "machine_id" bigint NOT NULL,
  "notification_type_id" bigint NOT NULL,
  "created_at" timestamp NOT NULL,
  "updated_at" timestamp NOT NULL
);

CREATE TABLE "part" (
  "id" bigserial PRIMARY KEY NOT NULL,
  "name" varchar(50),
  "description" text
);

CREATE TABLE "part_version" (
  "id" bigserial PRIMARY KEY NOT NULL,
  "part_id" bigint NOT NULL,
  "version" varchar(50),
  "description" text
);

CREATE TABLE "machine_part" (
  "id" bigserial PRIMARY KEY NOT NULL,
  "machine_id" bigint,
  "part_version_id" bigint NOT NULL
);

CREATE TABLE "command" (
  "id" bigserial PRIMARY KEY NOT NULL,
  "machine_id" bigint NOT NULL,
  "order_id" bigint,
  "user_id" bigint,
  "command" varchar(100) NOT NULL,
  "data" json,
  "response" text,
  "sent" bool DEFAULT false,
  "timeout" integer NOT NULL,
  "fail_if_not_ready" bool NOT NULL,
  "wait_for_response" bool NOT NULL,
  "wait_for_connection" integer NOT NULL,
  "created_at" timestamp NOT NULL,
  "updated_at" timestamp NOT NULL
);

CREATE UNIQUE INDEX "cylinder_client_id_detection_title_key" ON "cylinder" ("client_id", "detection_title");

CREATE UNIQUE INDEX "cylinder_client_id_title_key" ON "cylinder" ("client_id", "title");

CREATE UNIQUE INDEX "ix_cylinder_id" ON "cylinder" USING BTREE ("id");

CREATE INDEX "ix_cylinder_short_title" ON "cylinder" USING BTREE ("short_title");

CREATE INDEX "ix_cylinder_title" ON "cylinder" USING BTREE ("title");

CREATE UNIQUE INDEX "chamber_machine_key" ON "chamber" ("machine_id");

CREATE UNIQUE INDEX "ix_chamber_id" ON "chamber" USING BTREE ("id");

CREATE UNIQUE INDEX "ix_chamber_history_id" ON "chamber_history" USING BTREE ("id");

CREATE UNIQUE INDEX "ix_client_id" ON "client" USING BTREE ("id");

CREATE UNIQUE INDEX "ix_client_title" ON "client" USING BTREE ("title");

CREATE UNIQUE INDEX "ix_counter_type" ON "counter" USING BTREE ("type");

CREATE UNIQUE INDEX "ix_credit_id" ON "credit" USING BTREE ("id");

CREATE UNIQUE INDEX "ix_credit_usage_id" ON "credit_usage" USING BTREE ("id");

CREATE UNIQUE INDEX "ix_detection_attempt_id" ON "detection_attempt" USING BTREE ("id");

CREATE INDEX "ix_detection_attempt_order_id" ON "detection_attempt" USING BTREE ("order_id");

CREATE UNIQUE INDEX "ix_load_id" ON "load" USING BTREE ("id");

CREATE UNIQUE INDEX "ix_fill_order_id" ON "fill_order" USING BTREE ("id");

CREATE UNIQUE INDEX "ix_truck_id" ON "truck" USING BTREE ("id");

CREATE UNIQUE INDEX "ix_truck_location_history_id" ON "truck_location" USING BTREE ("id");

CREATE UNIQUE INDEX "ix_fill_order_cylinder_id" ON "fill_order_cylinder" USING BTREE ("id");

CREATE UNIQUE INDEX "ix_fix_order_id" ON "fix_order" USING BTREE ("id");

CREATE UNIQUE INDEX "machine_client_id_title_key" ON "machine" ("client_id", "title");

CREATE UNIQUE INDEX "ix_machine_id" ON "machine" USING BTREE ("id");

CREATE UNIQUE INDEX "machine_address_machine_id_key" ON "machine_address" ("machine_id");

CREATE UNIQUE INDEX "ix_machine_address_id" ON "machine_address" USING BTREE ("id");

CREATE UNIQUE INDEX "machine_lock_machine_id_key" ON "machine_lock" ("machine_id");

CREATE UNIQUE INDEX "ix_machine_lock_id" ON "machine_lock" USING BTREE ("id");

CREATE UNIQUE INDEX "machine_note_machine_id_key" ON "machine_note" ("machine_id");

CREATE UNIQUE INDEX "ix_machine_note_id" ON "machine_note" USING BTREE ("id");

CREATE UNIQUE INDEX "machine_cylinder_cylinder_id_machine_group_id_key" ON "machine_cylinder" ("cylinder_id", "machine_group_id");

CREATE UNIQUE INDEX "ix_machine_cylinder_id" ON "machine_cylinder" USING BTREE ("id");

CREATE UNIQUE INDEX "machine_group_client_id_title_key" ON "machine_group" ("client_id", "title");

CREATE UNIQUE INDEX "ix_machine_group_id" ON "machine_group" USING BTREE ("id");

CREATE UNIQUE INDEX "ix_machine_group_history_id" ON "machine_group_history" USING BTREE ("id");

CREATE UNIQUE INDEX "ix_machine_status_id" ON "machine_status" USING BTREE ("id");

CREATE UNIQUE INDEX "ix_machine_status_machine_id" ON "machine_status" USING BTREE ("machine_id");

CREATE UNIQUE INDEX "machine_user_ug_m_key" ON "machine_user" ("user_group_id", "machine_id");

CREATE UNIQUE INDEX "ix_notification_id" ON "notification" USING BTREE ("id");

CREATE UNIQUE INDEX "ix_notification_template_id" ON "notification_template" USING BTREE ("id");

CREATE UNIQUE INDEX "ix_notification_usage_id" ON "notification_usage" USING BTREE ("id");

CREATE UNIQUE INDEX "ix_payment_id" ON "payment" USING BTREE ("id");

CREATE UNIQUE INDEX "ix_payment_order_id" ON "payment" USING BTREE ("order_id");

CREATE UNIQUE INDEX "ix_refund_id" ON "refund" USING BTREE ("id");

CREATE UNIQUE INDEX "ix_refund_payment_id" ON "refund" USING BTREE ("payment_id");

CREATE UNIQUE INDEX "ix_payment_method_id" ON "payment_method" USING BTREE ("id");

CREATE UNIQUE INDEX "payment_method_config_client_id_title_key" ON "payment_method_config" ("client_id", "title");

CREATE UNIQUE INDEX "ix_payment_method_config_id" ON "payment_method_config" USING BTREE ("id");

CREATE UNIQUE INDEX "ix_permission_id" ON "permission" USING BTREE ("id");

CREATE UNIQUE INDEX "user_permission_permission_id_user_group_id_key" ON "user_permission" ("permission_id", "user_group_id");

CREATE UNIQUE INDEX "ix_user_permission_id" ON "user_permission" USING BTREE ("id");

CREATE UNIQUE INDEX "discount_price_id_schedule_id_key" ON "voucher" ("price_id", "schedule_id");

CREATE UNIQUE INDEX "ix_discount_id" ON "voucher" USING BTREE ("id");

CREATE UNIQUE INDEX "voucher_usage_voucher_id_user_id_key" ON "voucher_usage" ("voucher_id", "user_id");

CREATE UNIQUE INDEX "ix_voucher_usage_id" ON "voucher_usage" USING BTREE ("id");

CREATE UNIQUE INDEX "voucher_cylinder_voucher_id_cylinder_id_key" ON "voucher_cylinder" ("voucher_id", "cylinder_id");

CREATE UNIQUE INDEX "ix_voucher_cylinder_id" ON "voucher_cylinder" USING BTREE ("id");

CREATE UNIQUE INDEX "voucher_machine_group_voucher_id_machine_group_id_key" ON "voucher_machine_group" ("voucher_id", "machine_group_id");

CREATE UNIQUE INDEX "ix_voucher_machine_group_id" ON "voucher_machine_group" USING BTREE ("id");

CREATE UNIQUE INDEX "voucher_payment_method_voucher_id_payment_method_id_key" ON "voucher_payment_method" ("voucher_id", "payment_method_id");

CREATE UNIQUE INDEX "ix_voucher_payment_method_id" ON "voucher_payment_method" USING BTREE ("id");

CREATE UNIQUE INDEX "price_in_cylinder_id_out_cylinder_id_machine_group_id_key" ON "price" ("in_cylinder_id", "out_cylinder_id", "machine_group_id");

CREATE UNIQUE INDEX "ix_price_id" ON "price" USING BTREE ("id");

CREATE UNIQUE INDEX "ix_price_history_id" ON "price_history" USING BTREE ("id");

CREATE UNIQUE INDEX "ix_reserve_id" ON "reserve" USING BTREE ("id");

CREATE UNIQUE INDEX "ix_order_id" ON "order" USING BTREE ("id");

CREATE UNIQUE INDEX "ix_price_adjustment_id" ON "price_adjustment" USING BTREE ("id");

CREATE UNIQUE INDEX "ix_order_event_id" ON "order_event" USING BTREE ("id");

CREATE UNIQUE INDEX "ix_order_note_id" ON "order_note" USING BTREE ("id");

CREATE UNIQUE INDEX "ix_user_email" ON "user" USING BTREE ("email");

CREATE INDEX "ix_user_full_name" ON "user" USING BTREE ("full_name");

CREATE UNIQUE INDEX "ix_user_id" ON "user" USING BTREE ("id");

CREATE UNIQUE INDEX "ix_user_phone" ON "user" USING BTREE ("phone");

CREATE UNIQUE INDEX "user_group_client_id_title_key" ON "user_group" ("client_id", "title");

CREATE UNIQUE INDEX "ix_user_group_id" ON "user_group" USING BTREE ("id");

CREATE UNIQUE INDEX "ix_wishlist_id" ON "wishlist" USING BTREE ("id");

CREATE UNIQUE INDEX "ix_command_id" ON "command" USING BTREE ("id");

ALTER TABLE "cylinder" ADD FOREIGN KEY ("client_id") REFERENCES "client" ("id");

ALTER TABLE "external_cylinder" ADD FOREIGN KEY ("cylinder_id") REFERENCES "cylinder" ("id");

ALTER TABLE "chamber" ADD FOREIGN KEY ("machine_id") REFERENCES "machine" ("id");

ALTER TABLE "chamber" ADD FOREIGN KEY ("cylinder_id") REFERENCES "cylinder" ("id");

ALTER TABLE "chamber_history" ADD FOREIGN KEY ("chamber_id") REFERENCES "chamber" ("id");

ALTER TABLE "chamber_history" ADD FOREIGN KEY ("load_id") REFERENCES "load" ("id");

ALTER TABLE "chamber_history" ADD FOREIGN KEY ("order_id") REFERENCES "order" ("id");

ALTER TABLE "chamber_history" ADD FOREIGN KEY ("user_id") REFERENCES "user" ("id");

ALTER TABLE "chamber_history" ADD FOREIGN KEY ("cylinder_id") REFERENCES "cylinder" ("id");

ALTER TABLE "client" ADD FOREIGN KEY ("parent_id") REFERENCES "client" ("id");

ALTER TABLE "api_key" ADD FOREIGN KEY ("client_id") REFERENCES "client" ("id");

ALTER TABLE "api_key" ADD FOREIGN KEY ("user_group_id") REFERENCES "user_group" ("id");

ALTER TABLE "credit" ADD FOREIGN KEY ("original_order_id") REFERENCES "order" ("id");

ALTER TABLE "credit" ADD FOREIGN KEY ("order_id") REFERENCES "order" ("id");

ALTER TABLE "credit" ADD FOREIGN KEY ("client_id") REFERENCES "client" ("id");

ALTER TABLE "credit" ADD FOREIGN KEY ("user_id") REFERENCES "user" ("id");

ALTER TABLE "credit" ADD FOREIGN KEY ("machine_id") REFERENCES "machine" ("id");

ALTER TABLE "credit" ADD FOREIGN KEY ("cylinder_id") REFERENCES "cylinder" ("id");

ALTER TABLE "credit" ADD FOREIGN KEY ("creator_id") REFERENCES "user" ("id");

ALTER TABLE "credit_usage" ADD FOREIGN KEY ("credit_id") REFERENCES "credit" ("id");

ALTER TABLE "credit_usage" ADD FOREIGN KEY ("order_id") REFERENCES "order" ("id");

ALTER TABLE "detection_attempt" ADD FOREIGN KEY ("order_id") REFERENCES "order" ("id");

ALTER TABLE "detection_attempt" ADD FOREIGN KEY ("cylinder_id") REFERENCES "cylinder" ("id");

ALTER TABLE "load" ADD FOREIGN KEY ("machine_id") REFERENCES "machine" ("id");

ALTER TABLE "load" ADD FOREIGN KEY ("user_id") REFERENCES "user" ("id");

ALTER TABLE "load" ADD FOREIGN KEY ("fill_order_id") REFERENCES "fill_order" ("id");

ALTER TABLE "fill_order" ADD FOREIGN KEY ("created_by_id") REFERENCES "user" ("id");

ALTER TABLE "fill_order" ADD FOREIGN KEY ("assigned_to_id") REFERENCES "user" ("id");

ALTER TABLE "fill_order" ADD FOREIGN KEY ("truck_id") REFERENCES "truck" ("id");

ALTER TABLE "truck_location" ADD FOREIGN KEY ("fill_order_id") REFERENCES "fill_order" ("id");

ALTER TABLE "truck_location" ADD FOREIGN KEY ("truck_id") REFERENCES "truck" ("id");

ALTER TABLE "fill_order_cylinder" ADD FOREIGN KEY ("fill_order_id") REFERENCES "fill_order" ("id");

ALTER TABLE "fill_order_cylinder" ADD FOREIGN KEY ("cylinder_id") REFERENCES "cylinder" ("id");

ALTER TABLE "fill_order_cylinder" ADD FOREIGN KEY ("machine_id") REFERENCES "machine" ("id");

ALTER TABLE "fix_order" ADD FOREIGN KEY ("created_by_id") REFERENCES "user" ("id");

ALTER TABLE "fix_order" ADD FOREIGN KEY ("assigned_to_id") REFERENCES "user" ("id");

ALTER TABLE "fix_order" ADD FOREIGN KEY ("machine_id") REFERENCES "machine" ("id");

ALTER TABLE "machine" ADD FOREIGN KEY ("client_id") REFERENCES "client" ("id");

ALTER TABLE "machine" ADD FOREIGN KEY ("group_id") REFERENCES "machine_group" ("id");

ALTER TABLE "machine_address" ADD FOREIGN KEY ("machine_id") REFERENCES "machine" ("id");

ALTER TABLE "machine_lock" ADD FOREIGN KEY ("machine_id") REFERENCES "machine" ("id");

ALTER TABLE "machine_lock" ADD FOREIGN KEY ("user_id") REFERENCES "user" ("id");

ALTER TABLE "machine_note" ADD FOREIGN KEY ("machine_id") REFERENCES "machine" ("id");

ALTER TABLE "machine_note" ADD FOREIGN KEY ("user_id") REFERENCES "user" ("id");

ALTER TABLE "external_machine" ADD FOREIGN KEY ("machine_id") REFERENCES "machine" ("id");

ALTER TABLE "machine_cylinder" ADD FOREIGN KEY ("cylinder_id") REFERENCES "cylinder" ("id");

ALTER TABLE "machine_cylinder" ADD FOREIGN KEY ("machine_group_id") REFERENCES "machine_group" ("id");

ALTER TABLE "machine_group" ADD FOREIGN KEY ("client_id") REFERENCES "client" ("id");

ALTER TABLE "machine_group_history" ADD FOREIGN KEY ("machine_id") REFERENCES "machine" ("id");

ALTER TABLE "machine_group_history" ADD FOREIGN KEY ("group_id") REFERENCES "machine_group" ("id");

ALTER TABLE "machine_group_history" ADD FOREIGN KEY ("user_id") REFERENCES "user" ("id");

ALTER TABLE "machine_status" ADD FOREIGN KEY ("machine_id") REFERENCES "machine" ("id");

ALTER TABLE "machine_status" ADD FOREIGN KEY ("maintainer_id") REFERENCES "user" ("id");

ALTER TABLE "machine_user" ADD FOREIGN KEY ("user_group_id") REFERENCES "user_group" ("id");

ALTER TABLE "machine_user" ADD FOREIGN KEY ("machine_id") REFERENCES "machine" ("id");

ALTER TABLE "notification" ADD FOREIGN KEY ("client_id") REFERENCES "client" ("id");

ALTER TABLE "notification" ADD FOREIGN KEY ("machine_id") REFERENCES "machine" ("id");

ALTER TABLE "notification" ADD FOREIGN KEY ("notification_type_id") REFERENCES "notification_type" ("id");

ALTER TABLE "user_notifications" ADD FOREIGN KEY ("notification_type_id") REFERENCES "notification_type" ("id");

ALTER TABLE "user_notifications" ADD FOREIGN KEY ("user_id") REFERENCES "user" ("id");

ALTER TABLE "notification_usage" ADD FOREIGN KEY ("client_id") REFERENCES "client" ("id");

ALTER TABLE "notification_usage" ADD FOREIGN KEY ("notification_type_id") REFERENCES "notification_type" ("id");

ALTER TABLE "notification_usage" ADD FOREIGN KEY ("user_id") REFERENCES "user" ("id");

ALTER TABLE "notification_usage" ADD FOREIGN KEY ("machine_id") REFERENCES "machine" ("id");

ALTER TABLE "payment" ADD FOREIGN KEY ("order_id") REFERENCES "order" ("id");

ALTER TABLE "payment" ADD FOREIGN KEY ("payment_method_id") REFERENCES "payment_method" ("id");

ALTER TABLE "refund" ADD FOREIGN KEY ("payment_id") REFERENCES "payment" ("id");

ALTER TABLE "refund" ADD FOREIGN KEY ("refunded_by_id") REFERENCES "user" ("id");

ALTER TABLE "payment_method" ADD FOREIGN KEY ("machine_id") REFERENCES "machine" ("id");

ALTER TABLE "payment_method" ADD FOREIGN KEY ("config_id") REFERENCES "payment_method_config" ("id");

ALTER TABLE "payment_method_config" ADD FOREIGN KEY ("client_id") REFERENCES "client" ("id");

ALTER TABLE "user_permission" ADD FOREIGN KEY ("permission_id") REFERENCES "permission" ("id");

ALTER TABLE "user_permission" ADD FOREIGN KEY ("user_group_id") REFERENCES "user_group" ("id");

ALTER TABLE "schedule_item" ADD FOREIGN KEY ("schedule_id") REFERENCES "schedule" ("id");

ALTER TABLE "voucher" ADD FOREIGN KEY ("price_id") REFERENCES "price" ("id");

ALTER TABLE "voucher" ADD FOREIGN KEY ("machine_group_id") REFERENCES "machine_group" ("id");

ALTER TABLE "voucher" ADD FOREIGN KEY ("schedule_id") REFERENCES "schedule" ("id");

ALTER TABLE "voucher_usage" ADD FOREIGN KEY ("voucher_id") REFERENCES "voucher" ("id");

ALTER TABLE "voucher_usage" ADD FOREIGN KEY ("user_id") REFERENCES "user" ("id");

ALTER TABLE "voucher_usage" ADD FOREIGN KEY ("order_id") REFERENCES "order" ("id");

ALTER TABLE "voucher_cylinder" ADD FOREIGN KEY ("voucher_id") REFERENCES "voucher" ("id");

ALTER TABLE "voucher_cylinder" ADD FOREIGN KEY ("cylinder_id") REFERENCES "cylinder" ("id");

ALTER TABLE "voucher_machine_group" ADD FOREIGN KEY ("voucher_id") REFERENCES "voucher" ("id");

ALTER TABLE "voucher_machine_group" ADD FOREIGN KEY ("machine_group_id") REFERENCES "machine_group" ("id");

ALTER TABLE "voucher_payment_method" ADD FOREIGN KEY ("voucher_id") REFERENCES "voucher" ("id");

ALTER TABLE "voucher_payment_method" ADD FOREIGN KEY ("payment_method_id") REFERENCES "payment_method" ("id");

ALTER TABLE "price" ADD FOREIGN KEY ("in_cylinder_id") REFERENCES "cylinder" ("id");

ALTER TABLE "price" ADD FOREIGN KEY ("out_cylinder_id") REFERENCES "cylinder" ("id");

ALTER TABLE "price" ADD FOREIGN KEY ("machine_group_id") REFERENCES "machine_group" ("id");

ALTER TABLE "price" ADD FOREIGN KEY ("schedule_id") REFERENCES "schedule" ("id");

ALTER TABLE "price_history" ADD FOREIGN KEY ("price_id") REFERENCES "price" ("id");

ALTER TABLE "price_history" ADD FOREIGN KEY ("user_id") REFERENCES "user" ("id");

ALTER TABLE "reserve" ADD FOREIGN KEY ("user_id") REFERENCES "user" ("id");

ALTER TABLE "reserve" ADD FOREIGN KEY ("order_id") REFERENCES "order" ("id");

ALTER TABLE "reserve" ADD FOREIGN KEY ("cylinder_id") REFERENCES "cylinder" ("id");

ALTER TABLE "reserve" ADD FOREIGN KEY ("machine_id") REFERENCES "machine" ("id");

ALTER TABLE "order" ADD FOREIGN KEY ("machine_id") REFERENCES "machine" ("id");

ALTER TABLE "order" ADD FOREIGN KEY ("client_id") REFERENCES "client" ("id");

ALTER TABLE "order" ADD FOREIGN KEY ("in_cylinder_id") REFERENCES "cylinder" ("id");

ALTER TABLE "order" ADD FOREIGN KEY ("out_cylinder_id") REFERENCES "cylinder" ("id");

ALTER TABLE "order" ADD FOREIGN KEY ("in_chamber_id") REFERENCES "chamber" ("id");

ALTER TABLE "order" ADD FOREIGN KEY ("out_chamber_id") REFERENCES "chamber" ("id");

ALTER TABLE "order" ADD FOREIGN KEY ("user_id") REFERENCES "user" ("id");

ALTER TABLE "order" ADD FOREIGN KEY ("creator_id") REFERENCES "user" ("id");

ALTER TABLE "order" ADD FOREIGN KEY ("price_history_id") REFERENCES "price_history" ("id");

ALTER TABLE "price_adjustment" ADD FOREIGN KEY ("order_id") REFERENCES "order" ("id");

ALTER TABLE "order_event" ADD FOREIGN KEY ("order_id") REFERENCES "order" ("id");

ALTER TABLE "order_event" ADD FOREIGN KEY ("user_id") REFERENCES "user" ("id");

ALTER TABLE "order_note" ADD FOREIGN KEY ("order_id") REFERENCES "order" ("id");

ALTER TABLE "order_note" ADD FOREIGN KEY ("user_id") REFERENCES "user" ("id");

ALTER TABLE "user" ADD FOREIGN KEY ("client_id") REFERENCES "client" ("id");

ALTER TABLE "user" ADD FOREIGN KEY ("group_id") REFERENCES "user_group" ("id");

ALTER TABLE "user_group" ADD FOREIGN KEY ("client_id") REFERENCES "client" ("id");

ALTER TABLE "wishlist" ADD FOREIGN KEY ("user_id") REFERENCES "user" ("id");

ALTER TABLE "wishlist" ADD FOREIGN KEY ("cylinder_id") REFERENCES "cylinder" ("id");

ALTER TABLE "wishlist" ADD FOREIGN KEY ("machine_id") REFERENCES "machine" ("id");

ALTER TABLE "wishlist" ADD FOREIGN KEY ("notification_type_id") REFERENCES "notification_type" ("id");

ALTER TABLE "part_version" ADD FOREIGN KEY ("part_id") REFERENCES "part" ("id");

ALTER TABLE "machine_part" ADD FOREIGN KEY ("machine_id") REFERENCES "machine" ("id");

ALTER TABLE "machine_part" ADD FOREIGN KEY ("part_version_id") REFERENCES "part_version" ("id");

ALTER TABLE "command" ADD FOREIGN KEY ("machine_id") REFERENCES "machine" ("id");

ALTER TABLE "command" ADD FOREIGN KEY ("order_id") REFERENCES "order" ("id");

ALTER TABLE "command" ADD FOREIGN KEY ("user_id") REFERENCES "user" ("id");
