class RemoveAgreedtolicenseFromSubmission < ActiveRecord::Migration[4.2]
  def change
    remove_column :submissions, :agreed_to_license, :boolean
  end
end
