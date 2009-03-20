class CreateFeedbacks < ActiveRecord::Migration
  def self.up
    create_table :feedbacks do |t|
      t.string  :url
      t.string  :author
      t.text    :description
      t.integer :project_id
      t.integer :polarity
      t.boolean :delta
      
      t.timestamps
    end
  end

  def self.down
    drop_table :feedbacks
  end
end
