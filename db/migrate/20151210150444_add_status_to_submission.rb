class AddStatusToSubmission < ActiveRecord::Migration
  def change
    add_column :submissions, :status, :string
    add_column :submissions, :handle, :string
  end
end
