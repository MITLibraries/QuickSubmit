class AddDocumentsToSubmissions < ActiveRecord::Migration
  def change
    add_column :submissions, :documents, :string
  end
end
