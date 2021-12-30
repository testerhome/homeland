# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_12_17_182826) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_stat_statements"
  enable_extension "plpgsql"

  create_table "actions", id: :serial, force: :cascade do |t|
    t.string "action_type", null: false
    t.string "action_option"
    t.string "target_type"
    t.integer "target_id"
    t.string "user_type"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["target_type", "target_id", "action_type"], name: "index_actions_on_target_type_and_target_id_and_action_type"
    t.index ["user_type", "user_id", "action_type"], name: "index_actions_on_user_type_and_user_id_and_action_type"
  end

  create_table "ads", force: :cascade do |t|
    t.string "topic_id", null: false
    t.string "topic_title", null: false
    t.string "topic_author", null: false
    t.string "cover", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["topic_id"], name: "index_ads_on_topic_id"
  end

  create_table "appends", force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "topic_id"
    t.index ["topic_id"], name: "index_appends_on_topic_id"
  end

  create_table "authorizations", id: :serial, force: :cascade do |t|
    t.string "provider", null: false
    t.string "uid", limit: 1000, null: false
    t.integer "user_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["provider", "uid"], name: "index_authorizations_on_provider_and_uid"
  end

  create_table "columns", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "cover"
    t.integer "user_id", null: false
    t.string "who_deleted"
    t.integer "modified_admin_id"
    t.integer "likes_count", default: 0
    t.datetime "suggested_at"
    t.datetime "deleted_at"
    t.string "slug", null: false
    t.datetime "unseal_time"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "followers_count", default: 0
    t.integer "articles_count", default: 0, null: false
    t.index ["likes_count"], name: "index_columns_on_likes_count"
    t.index ["name"], name: "index_columns_on_name"
    t.index ["suggested_at"], name: "index_columns_on_suggested_at"
  end

  create_table "comments", id: :serial, force: :cascade do |t|
    t.text "body", null: false
    t.integer "user_id", null: false
    t.string "commentable_type"
    t.integer "commentable_id"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["commentable_id"], name: "index_comments_on_commentable_id"
    t.index ["commentable_type"], name: "index_comments_on_commentable_type"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "credit_products", force: :cascade do |t|
    t.string "title"
    t.string "main_image_url"
    t.string "category"
    t.string "description"
    t.string "state"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "position"
    t.boolean "online", default: true
    t.string "uuid"
  end

  create_table "credit_records", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "category"
    t.string "reason"
    t.integer "num"
    t.string "operator"
    t.jsonb "meta"
    t.string "markup"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "model_id"
    t.string "model_type"
    t.integer "balance"
    t.index ["model_id"], name: "index_credit_records_on_model_id"
    t.index ["model_type"], name: "index_credit_records_on_model_type"
    t.index ["user_id"], name: "index_credit_records_on_user_id"
  end

  create_table "credit_variant_orders", force: :cascade do |t|
    t.bigint "credit_variant_id", null: false
    t.integer "num"
    t.boolean "online", default: false
    t.string "status"
    t.bigint "user_id", null: false
    t.string "deliver_address"
    t.string "deliver_category"
    t.string "deliver_markup"
    t.string "deliver_no"
    t.string "deliver_receiver_name"
    t.string "deliver_receiver_phone"
    t.decimal "current_credit_price"
    t.integer "authen_user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "uuid"
    t.string "virtual_markup"
    t.index ["credit_variant_id"], name: "index_credit_variant_orders_on_credit_variant_id"
    t.index ["user_id"], name: "index_credit_variant_orders_on_user_id"
  end

  create_table "credit_variants", force: :cascade do |t|
    t.string "sku"
    t.string "image_url"
    t.string "title"
    t.string "description"
    t.bigint "credit_product_id"
    t.decimal "credit_price", precision: 8, scale: 2, default: "0.0", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "stock"
    t.integer "position"
    t.boolean "online", default: true
    t.index ["credit_product_id"], name: "index_credit_variants_on_credit_product_id"
  end

  create_table "devices", id: :serial, force: :cascade do |t|
    t.integer "platform", null: false
    t.integer "user_id", null: false
    t.string "token", null: false
    t.datetime "last_actived_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_devices_on_user_id"
  end

  create_table "exception_tracks", id: :serial, force: :cascade do |t|
    t.string "title"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "github_statistics", force: :cascade do |t|
    t.string "github_user"
    t.string "testerhome_user"
    t.integer "ttf_contribution"
    t.integer "monthly_contribution"
    t.integer "discovery_contribution"
    t.date "data_of_month"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["data_of_month"], name: "index_github_statistics_on_data_of_month"
    t.index ["github_user"], name: "index_github_statistics_on_github_user"
    t.index ["testerhome_user"], name: "index_github_statistics_on_testerhome_user"
  end

  create_table "homeland_activities_events", force: :cascade do |t|
    t.string "city"
    t.string "category"
    t.string "title"
    t.datetime "start_at"
    t.datetime "end_at"
    t.datetime "registration_open_at"
    t.datetime "registration_end_at"
    t.datetime "suggested_at"
    t.string "register_category"
    t.string "register_category_info"
    t.string "event_city"
    t.string "event_city_info"
    t.string "description"
    t.json "operator_info"
    t.string "realname"
    t.string "email"
    t.string "phone"
    t.string "wechat_or_qq"
    t.string "status", default: "init"
    t.integer "user_id"
    t.integer "comments_count", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "photo_url"
  end

  create_table "invite_codes", force: :cascade do |t|
    t.string "code", null: false
    t.string "creater_id"
    t.string "consumer_id"
    t.bigint "expired_in"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["code"], name: "index_invite_codes_on_code"
  end

  create_table "locations", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.integer "users_count", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name"], name: "index_locations_on_name"
  end

  create_table "nodes", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "summary"
    t.integer "section_id", null: false
    t.integer "sort", default: 0, null: false
    t.integer "topics_count", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["section_id"], name: "index_nodes_on_section_id"
    t.index ["sort"], name: "index_nodes_on_sort"
  end

  create_table "notes", id: :serial, force: :cascade do |t|
    t.string "title", null: false
    t.text "body", null: false
    t.integer "user_id", null: false
    t.integer "word_count", default: 0, null: false
    t.integer "changes_count", default: 0, null: false
    t.boolean "publish", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["user_id"], name: "index_notes_on_user_id"
  end

  create_table "notifications", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "actor_id"
    t.string "notify_type", null: false
    t.string "target_type"
    t.integer "target_id"
    t.string "second_target_type"
    t.integer "second_target_id"
    t.string "third_target_type"
    t.integer "third_target_id"
    t.datetime "read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "message"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "oauth_access_grants", id: :serial, force: :cascade do |t|
    t.integer "resource_owner_id", null: false
    t.integer "application_id", null: false
    t.string "token", null: false
    t.bigint "expires_in"
    t.text "redirect_uri", null: false
    t.datetime "created_at", null: false
    t.datetime "revoked_at"
    t.string "scopes"
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true
  end

  create_table "oauth_access_tokens", id: :serial, force: :cascade do |t|
    t.integer "resource_owner_id"
    t.integer "application_id"
    t.string "token", null: false
    t.string "refresh_token"
    t.bigint "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at", null: false
    t.string "scopes"
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true
  end

  create_table "oauth_applications", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "uid", null: false
    t.string "secret", null: false
    t.text "redirect_uri", null: false
    t.string "scopes", default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "owner_id"
    t.string "owner_type"
    t.integer "level", default: 0, null: false
    t.boolean "confidential", default: true, null: false
    t.index ["owner_id", "owner_type"], name: "index_oauth_applications_on_owner_id_and_owner_type"
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

  create_table "opensource_projects", id: :serial, force: :cascade do |t|
    t.string "title", null: false
    t.string "avatar"
    t.string "license"
    t.string "dev_language"
    t.string "operator_os"
    t.string "doc_url"
    t.string "proj_url"
    t.string "slug", null: false
    t.text "body", null: false
    t.string "summary", limit: 5000
    t.string "banner"
    t.integer "user_id"
    t.integer "likes_count", default: 0, null: false
    t.integer "comments_count", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.datetime "published_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.datetime "suggested_at"
    t.index ["deleted_at"], name: "index_opensource_projects_on_deleted_at"
    t.index ["published_at"], name: "index_opensource_projects_on_published_at"
    t.index ["slug"], name: "index_opensource_projects_on_slug"
    t.index ["status"], name: "index_opensource_projects_on_status"
    t.index ["suggested_at"], name: "index_opensource_projects_on_suggested_at"
    t.index ["user_id"], name: "index_opensource_projects_on_user_id"
  end

  create_table "page_versions", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "page_id", null: false
    t.integer "version", default: 0, null: false
    t.string "slug", null: false
    t.string "title", null: false
    t.text "desc", null: false
    t.text "body", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["page_id"], name: "index_page_versions_on_page_id"
  end

  create_table "pages", id: :serial, force: :cascade do |t|
    t.string "slug", null: false
    t.string "title", null: false
    t.text "body", null: false
    t.boolean "locked", default: false
    t.integer "version", default: 0, null: false
    t.integer "editor_ids", default: [], null: false, array: true
    t.integer "word_count", default: 0, null: false
    t.integer "changes_cout", default: 1, null: false
    t.integer "comments_count", default: 0, null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_pages_on_slug", unique: true
  end

  create_table "photos", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "image", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["user_id"], name: "index_photos_on_user_id"
  end

  create_table "profiles", force: :cascade do |t|
    t.integer "user_id", null: false
    t.jsonb "contacts", default: {}, null: false
    t.jsonb "rewards", default: {}, null: false
    t.jsonb "preferences", default: {}, null: false
    t.index ["user_id"], name: "index_profiles_on_user_id", unique: true
  end

  create_table "replies", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "topic_id", null: false
    t.text "body", null: false
    t.integer "state", default: 1, null: false
    t.integer "likes_count", default: 0
    t.integer "mentioned_user_ids", default: [], array: true
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "action"
    t.string "target_type"
    t.string "target_id"
    t.integer "reply_to_id"
    t.integer "real_user_id"
    t.integer "anonymous", default: 0, null: false
    t.boolean "exposed_to_author_only", default: false, null: false
    t.datetime "suggested_at"
    t.datetime "audited_at"
    t.integer "audit_user_id"
    t.string "audit_status", default: "pending"
    t.string "audit_reason"
    t.index ["deleted_at"], name: "index_replies_on_deleted_at"
    t.index ["topic_id"], name: "index_replies_on_topic_id"
    t.index ["user_id"], name: "index_replies_on_user_id"
  end

  create_table "search_documents", force: :cascade do |t|
    t.string "searchable_type", limit: 32, null: false
    t.integer "searchable_id", null: false
    t.tsvector "tokens"
    t.text "content"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["searchable_type", "searchable_id"], name: "index_search_documents_on_searchable_type_and_searchable_id", unique: true
    t.index ["tokens"], name: "index_search_documents_on_tokens", using: :gin
  end

  create_table "sections", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.integer "sort", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["sort"], name: "index_sections_on_sort"
  end

  create_table "settings", id: :serial, force: :cascade do |t|
    t.string "var", null: false
    t.text "value"
    t.integer "thing_id"
    t.string "thing_type", limit: 30
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["thing_type", "thing_id", "var"], name: "index_settings_on_thing_type_and_thing_id_and_var", unique: true
  end

  create_table "site_nodes", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.integer "sort", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["sort"], name: "index_site_nodes_on_sort"
  end

  create_table "sites", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "site_node_id"
    t.string "name", null: false
    t.string "url", null: false
    t.string "desc"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["site_node_id", "deleted_at"], name: "index_sites_on_site_node_id_and_deleted_at"
    t.index ["site_node_id"], name: "index_sites_on_site_node_id"
    t.index ["url"], name: "index_sites_on_url"
  end

  create_table "team_profiles", force: :cascade do |t|
    t.integer "team_id", null: false
    t.text "apply_message"
    t.boolean "show_reward", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "team_users", id: :serial, force: :cascade do |t|
    t.integer "team_id", null: false
    t.integer "user_id", null: false
    t.integer "role"
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "comment"
    t.boolean "is_receive_notifications", default: true, null: false
    t.index ["team_id"], name: "index_team_users_on_team_id"
    t.index ["user_id"], name: "index_team_users_on_user_id"
  end

  create_table "tip_offs", force: :cascade do |t|
    t.integer "reporter_id"
    t.string "reporter_email"
    t.string "tip_off_type"
    t.string "body"
    t.datetime "create_time"
    t.string "content_url"
    t.string "content_author_id"
    t.integer "follower_id"
    t.datetime "follow_time"
    t.string "follow_result"
    t.datetime "deleted_at"
    t.index ["reporter_id"], name: "index_tip_offs_on_reporter_id"
  end

  create_table "topics", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "node_id", null: false
    t.string "title", null: false
    t.text "body", null: false
    t.integer "last_reply_id"
    t.integer "last_reply_user_id"
    t.string "last_reply_user_login"
    t.string "node_name"
    t.string "who_deleted"
    t.integer "last_active_mark"
    t.boolean "lock_node", default: false
    t.datetime "suggested_at"
    t.integer "grade", default: 0
    t.datetime "replied_at"
    t.integer "replies_count", default: 0, null: false
    t.integer "likes_count", default: 0
    t.integer "mentioned_user_ids", default: [], array: true
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "closed_at"
    t.integer "team_id"
    t.integer "real_user_id"
    t.boolean "draft", default: true, null: false
    t.string "type"
    t.boolean "article_public", default: true, null: false
    t.integer "column_id"
    t.integer "modified_admin_id"
    t.boolean "cannot_be_shared", default: false
    t.integer "suggested_node"
    t.datetime "audited_at"
    t.integer "audit_user_id"
    t.string "audit_status", default: "pending"
    t.string "audit_reason"
    t.index ["deleted_at"], name: "index_topics_on_deleted_at"
    t.index ["grade"], name: "index_topics_on_grade"
    t.index ["last_active_mark"], name: "index_topics_on_last_active_mark"
    t.index ["last_reply_id"], name: "index_topics_on_last_reply_id"
    t.index ["likes_count"], name: "index_topics_on_likes_count"
    t.index ["node_id", "deleted_at"], name: "index_topics_on_node_id_and_deleted_at"
    t.index ["suggested_at"], name: "index_topics_on_suggested_at"
    t.index ["team_id"], name: "index_topics_on_team_id"
    t.index ["user_id"], name: "index_topics_on_user_id"
  end

  create_table "user_ssos", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "uid", null: false
    t.string "username"
    t.string "email"
    t.string "name"
    t.string "avatar_url"
    t.text "last_payload", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["uid"], name: "index_user_ssos_on_uid", unique: true
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "login", limit: 100, null: false
    t.string "name", limit: 100
    t.string "email", null: false
    t.string "email_md5", null: false
    t.boolean "email_public", default: false, null: false
    t.string "location"
    t.integer "location_id"
    t.string "bio"
    t.string "website"
    t.string "company"
    t.string "github"
    t.string "twitter"
    t.string "avatar"
    t.integer "state", default: 1, null: false
    t.string "tagline"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "password_salt", default: "", null: false
    t.string "persistence_token", default: "", null: false
    t.string "single_access_token", default: "", null: false
    t.string "perishable_token", default: "", null: false
    t.integer "topics_count", default: 0, null: false
    t.integer "replies_count", default: 0, null: false
    t.integer "follower_ids", default: [], array: true
    t.string "type", limit: 20
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.integer "team_users_count"
    t.integer "followers_count", default: 0
    t.integer "following_count", default: 0
    t.integer "columns_count", default: 0
    t.boolean "private", default: false, null: false
    t.datetime "certified_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "score", default: 1000, null: false
    t.string "wechat"
    t.boolean "wechat_public"
    t.string "qq"
    t.boolean "qq_public"
    t.string "weibo"
    t.boolean "weibo_public"
    t.string "co"
    t.string "qrcode"
    t.integer "node_assignment_ids", default: [], array: true
    t.integer "credit_sum"
    t.datetime "audited_at"
    t.integer "audit_user_id"
    t.string "audit_status", default: "pending"
    t.string "audit_reason"
    t.index "lower((login)::text) varchar_pattern_ops", name: "index_users_on_lower_login_varchar_pattern_ops"
    t.index "lower((name)::text) varchar_pattern_ops", name: "index_users_on_lower_name_varchar_pattern_ops"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["github"], name: "index_users_on_github"
    t.index ["location"], name: "index_users_on_location"
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  add_foreign_key "appends", "topics"
  add_foreign_key "credit_records", "users"
  add_foreign_key "credit_variant_orders", "credit_variants"
  add_foreign_key "credit_variant_orders", "users"
end
