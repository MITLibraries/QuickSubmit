class AddStatusToSubmission < ActiveRecord::Migration[4.2]
  def change
    add_column :submissions, :status, :string
    add_column :submissions, :handle, :string
  end
end
