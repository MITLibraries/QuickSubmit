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
#  documents         :string
#  status            :string
#  handle            :string
#

class Submission < ActiveRecord::Base
  belongs_to :user
  validates :user, presence: true
  validates :title, presence: true
  validates :agreed_to_license, inclusion: { in: [true] }
  validates :documents, presence: true
  mount_uploaders :documents, DocumentUploader
  serialize :documents, JSON
  before_create :generate_uuid

  def to_mets
    Mets.new(self).to_xml
  end

  def sword_path
    md5 = Digest::MD5.new
    "tmp/#{md5.update(id.to_s)}.zip"
  end

  def generate_uuid
    self.uuid = SecureRandom.uuid
  end

  def to_sword_package
    Zip::File.open(sword_path, Zip::File::CREATE) do |zipfile|
      documents.each do |document|
        zipfile.add(document.file.filename, document.file.file)
      end
      zipfile.get_output_stream('mets.xml') { |os| os.write to_mets }
    end
  end
end
