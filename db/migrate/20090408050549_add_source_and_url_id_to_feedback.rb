class AddSourceAndUrlIdToFeedback < ActiveRecord::Migration
  def self.up
    add_column   :feedbacks, :source, :integer
    add_column   :feedbacks, :url_id, :string
    
    add_index    :feedbacks, :url_id, :unique => true
    remove_index :feedbacks, :url
  end

  def self.down
    remove_column :feedbacks, :source
    remove_column :feedbacks, :url_id
    
    remove_index  :feedbacks, :url_id
    add_index     :feedbacks, :url, :unique => true
  end
end
