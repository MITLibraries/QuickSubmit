# == Schema Information
#
# Table name: submissions
#
#  id                :integer          not null, primary key
#  user_id           :integer
#  title             :string           not null
#  journal           :string
#  doi               :string
#  author            :string
#  doe               :boolean
#  grant_number      :string
#  agreed_to_license :boolean
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class Submission < ActiveRecord::Base
  belongs_to :user
  validates :user, presence: true
  validates :title, presence: true
  validates :agreed_to_license, inclusion: { in: [true] }
end
