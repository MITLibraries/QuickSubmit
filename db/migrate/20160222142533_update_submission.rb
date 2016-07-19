class UpdateSubmission < ActiveRecord::Migration[4.2]
  def change
    change_table :submissions do |t|
      t.remove :author, :doe, :grant_number
      t.datetime :pub_date
      t.string :funders
    end
  end
end
