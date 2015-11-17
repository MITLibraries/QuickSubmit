class CreateSubmissions < ActiveRecord::Migration
  def change
    create_table :submissions do |t|
      t.belongs_to :user, index: true

      t.string :title, null: false
      t.string :journal
      t.string :doi
      t.string :author
      t.boolean :doe
      t.string :grant_number
      t.boolean :agreed_to_license

      t.timestamps null: false
    end
  end
end
