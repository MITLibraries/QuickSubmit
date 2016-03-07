class RemoveAgreedtolicenseFromSubmission < ActiveRecord::Migration
  def change
    remove_column :submissions, :agreed_to_license, :boolean
  end
end
