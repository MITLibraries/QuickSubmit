# == Schema Information
#
# Table name: submissions
#
#  id                :integer          not null, primary key
#  user_id           :integer
#  title             :string           not null
#  journal           :string
#  doi               :string
#  agreed_to_license :boolean
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  documents         :string
#  status            :string
#  handle            :string
#  uuid              :string
#  pub_date          :datetime
#  funders           :string
#

class Submission < ActiveRecord::Base
  belongs_to :user
  validates :user, presence: true
  validates :title, presence: true
  validates :agreed_to_license, inclusion: { in: [true] }
  validates :documents, presence: true
  validates :funders, presence: true
  validates :handle, format: URI.regexp, allow_nil: true
  validates :handle, presence: true, if: :status_approved?
  serialize :documents, JSON
  serialize :funders, JSON
  before_create :generate_uuid

  def status_approved?
    status == 'approved'
  end

  def to_mets(callback)
    Mets.new(self, callback).to_xml
  end

  def sword_path
    md5 = Digest::MD5.new
    "tmp/#{md5.update(id.to_s)}.zip"
  end

  def generate_uuid
    self.uuid = SecureRandom.uuid
  end

  def send_status_email
    case status
    when 'in review queue'
      SubmissionMailer.queued(self).deliver_now
    when 'deposited', 'approved'
      SubmissionMailer.deposited(self).deliver_now
    when 'rejected'
      SubmissionMailer.rejected(self).deliver_now
    end
  end

  def to_sword_package(callback)
    Zip::File.open(sword_path, Zip::File::CREATE) do |zipfile|
      documents.each do |document|
        zipfile.get_output_stream(document.split('/').last) do |os|
          os.write RestClient.get document_uri(document)
        end
      end
      zipfile.get_output_stream('mets.xml') { |os| os.write to_mets(callback) }
    end
  end

  def document_uri(document)
    if document.include?('localhost')
      swap = "localhost:10001/#{ENV['S3_BUCKET']}/"
      "http:#{document.gsub('localhost/', swap)}"
    else
      "https:#{document}"
    end
  end

  def valid_funders
    ['Department of Defense (DoD)',
     'Department of Energy (DOE)',
     'Department of Transportation (DOT)',
     'National Aeronautics and Space Administration (NASA)',
     'National Institutes of Health (NIH)',
     'National Center for Atmospheric Research (NCAR)',
     'National Ocean and Atmospheric Administration (NOAA)',
     'National Science Foundation (NSF)',
     'United States Department of Agriculture (USDA)',
     'None / Other']
  end
end
