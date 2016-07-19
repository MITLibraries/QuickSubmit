class AddUuidToSubmission < ActiveRecord::Migration[4.2]
  def change
    add_column :submissions, :uuid, :string
  end
end
