class AddUuidToSubmission < ActiveRecord::Migration
  def change
    add_column :submissions, :uuid, :string
  end
end
