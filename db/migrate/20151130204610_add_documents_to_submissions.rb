class AddDocumentsToSubmissions < ActiveRecord::Migration[4.2]
  def change
    add_column :submissions, :documents, :string
  end
end
