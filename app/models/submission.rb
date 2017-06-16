# == Schema Information
#
# Table name: submissions
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  title      :string           not null
#  journal    :string
#  doi        :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  documents  :string
#  status     :string
#  handle     :string
#  uuid       :string
#  pub_date   :datetime
#  funders    :string
#

# A {User} supplied set of metadata with attached documents
class Submission < ActiveRecord::Base
  belongs_to :user
  attr_accessor :publication_year, :publication_month
  validates :publication_year, presence: true
  validate :valid_year?
  validates :publication_month, presence: true
  validate :valid_month?
  validates :user, presence: true
  validates :title, presence: { message: 'A title is required.' }
  validates :documents, presence: { message:
                                    'One or more documents is required.' }
  validates :funders, presence: { message: 'At least one funder is required.' }
  validate :funders_are_valid
  validates :handle, format: URI.regexp, allow_nil: true
  validates :handle, presence: true, if: :status_approved?
  serialize :documents, JSON
  serialize :funders, JSON
  before_create :generate_uuid
  before_create :combine_publication_date
  before_destroy :delete_documents_from_s3
  after_find :split_publication_date

  SUBMITTABLE_FUNDERS = ['Department of Agriculture (USDA)',
                         'Department of Defense (DoD)',
                         'Department of Energy (DOE)',
                         'Department of Homeland Security (DHS)',
                         'Department of Labor',
                         'Department of Transportation (DOT)',
                         'Environmental Protection Agency (EPA)',
                         'National Aeronautics and Space Administration (NASA)',
                         'National Institutes of Health (NIH)',
                         'National Ocean and Atmospheric Administration (NOAA)',
                         'National Science Foundation (NSF)',
                         'US Geological Survey (USGS)'].freeze

  UI_ONLY_FUNDERS = ['Other'].freeze

  # Ensures submitted year string is reasonably sane
  def valid_year?
    d=publication_year, s=Time.zone.now.year-5, e=Time.zone.now.year+5
    if d.grep(/^(\d)+$/) do |date_str|
      (s..e).include?(date_str.to_i)
    end.first
    else
      errors.add(:publication_year, 'Invalid publication year')
    end
  end

  def valid_month?
    return if Date::MONTHNAMES.compact.include?(publication_month)
    errors.add(:publication_month, 'Invalid publication month')
  end

  # Ensures submitted funders are allowed
  def funders_are_valid
    return unless funders.present?
    funders.each do |funder|
      next if valid_funders.include?(funder)
      errors.add(:funders, 'Invalid funder detected')
    end
  end

  # Convience method to check if the Submission status is 'approved'
  def status_approved?
    status == 'approved'
  end

  # Combine the UI supplied month and year into a datetime object
  def combine_publication_date
    self.pub_date = DateTime.new(publication_year.to_i,
                                 Date::MONTHNAMES.index(publication_month))
  end

  def split_publication_date
    self.publication_year = pub_date.strftime('%Y')
    self.publication_month = pub_date.strftime('%B')
  end

  # Generate a {Mets} XML representation of the Submission
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

  # Returns a usable URI associated S3 documents
  # @param document
  #   A reference to an S3 document from Submission.documents
  # @return a usable URI based on whether or not fakes3 or real
  #   S3 is being used.
  def document_uri(document)
    if document.include?('localhost')
      swap = "localhost:10001/#{ENV['S3_BUCKET']}/"
      URI.escape("http:#{document.gsub('localhost/', swap)}")
    else
      URI.escape("https:#{document}")
    end
  end

  # Deletes all S3 content associated with a Submission
  def delete_documents_from_s3
    documents.each do |doc|
      obj = Submission.document_key(doc)
      S3_BUCKET.object(obj).delete
    end
  end

  def self.local_document_keys
    Submission.all.map(&:documents).flatten.map { |k| document_key(k) }
  end

  def self.document_key(doc)
    "uploads#{doc.split('uploads').last}"
  end

  # An array of funders that does not include UI only funders
  def funders_minus_ui_only_funders
    funders - ui_only_funders
  end

  # This includes both funders we want to include in METS and
  # funders that we only want to display in the UI
  # @note this array is used to both generate the UI and validate the input
  def valid_funders
    submittable_funders + ui_only_funders
  end

  # Funders we want to display in the UI and also include in {Mets}
  def submittable_funders
    SUBMITTABLE_FUNDERS
  end

  # Funders we want to display in the UI, but not include in {Mets}
  def ui_only_funders
    UI_ONLY_FUNDERS
  end
end
