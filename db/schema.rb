# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090408050549) do

  create_table "feedbacks", :force => true do |t|
    t.string   "url"
    t.string   "author_name"
    t.string   "author_image"
    t.string   "author_url"
    t.text     "description"
    t.integer  "project_id"
    t.integer  "polarity"
    t.boolean  "delta"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "source"
    t.string   "url_id"
  end

  add_index "feedbacks", ["url_id"], :name => "index_feedbacks_on_url_id", :unique => true

  create_table "projects", :force => true do |t|
    t.string   "name"
    t.string   "url"
    t.text     "description"
    t.boolean  "featured"
    t.string   "must_have_words"
    t.string   "must_not_have_words"
    t.boolean  "use_spam_filter"
    t.boolean  "delta"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
