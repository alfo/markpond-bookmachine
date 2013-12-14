class CreateBookmarks < ActiveRecord::Migration
  def self.up
    create_table "bookmarks", :force => true do |t|
      t.string   "url"
      t.string   "archive_url"
      t.string   "title"
      t.string   "excerpt"
      t.string   "via"
      t.datetime "bookmarked_at"
      t.string   "raw_tags"
      t.datetime "created_at",    :null => false
      t.datetime "updated_at",    :null => false
    end
  end

  def self.down
    remove_table "bookmarks"
  end
end
