class CreateProjects < ActiveRecord::Migration
  def self.up
    create_table :projects do |t|
      t.string  :name
      t.string  :url
      t.text    :description
      t.boolean :featured
      t.string  :must_have_words
      t.string  :must_not_have_words
      
      t.boolean :delta

      t.timestamps
    end
  end

  def self.down
    drop_table :projects
  end
end
