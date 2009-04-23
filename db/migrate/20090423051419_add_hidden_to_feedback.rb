class AddHiddenToFeedback < ActiveRecord::Migration
  def self.up
    add_column   :feedbacks, :hidden, :boolean
  end

  def self.down
    remove_column   :feedbacks, :hidden
  end
end
