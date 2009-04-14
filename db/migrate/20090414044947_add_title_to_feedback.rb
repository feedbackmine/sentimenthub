class AddTitleToFeedback < ActiveRecord::Migration
  def self.up
    add_column   :feedbacks, :title, :string
  end

  def self.down
    remove_column :feedbacks, :title
  end
end
