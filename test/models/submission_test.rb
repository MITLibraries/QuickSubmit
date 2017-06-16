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

require 'test_helper'

class SubmissionTest < ActiveSupport::TestCase
  test 'valid submission' do
    sub = submissions(:sub_one)
    assert sub.valid?
  end

  test 'invalid without title' do
    sub = submissions(:sub_one)
    sub.title = ''
    assert_not sub.valid?
  end

  test 'invalid without user' do
    sub = submissions(:sub_one)
    sub.user_id = ''
    assert_not sub.valid?
  end

  test 'invalid without documents' do
    sub = submissions(:sub_one)
    sub.documents = ''
    assert_not sub.valid?
  end

  test 'invalid without funders' do
    sub = submissions(:sub_one)
    sub.funders = ''
    assert_not sub.valid?
  end

  test 'invalid without valid funder' do
    sub = submissions(:sub_one)
    sub.funders << 'Fake Funder'
    assert_not sub.valid?
  end

  test 'invalid with at least one invalid funder' do
    sub = submissions(:sub_one)
    sub.funders = ['Fake Funder']
    assert_not sub.valid?
  end

  test 'invalid without publication_year' do
    sub = submissions(:sub_one)
    sub.publication_year = ''
    assert_not sub.valid?
  end

  test 'invalid without publication_month' do
    sub = submissions(:sub_one)
    sub.publication_month = ''
    assert_not sub.valid?
  end

  test 'valid with a ui only funder' do
    sub = submissions(:sub_one)
    sub.funders = ['Other']
    assert sub.valid?
  end

  test 'funders_minus_ui_only_funders' do
    sub = submissions(:sub_one)
    sub.funders << 'Other'
    assert_equal(sub.funders.include?('Other'), true)
    assert_equal(sub.funders_minus_ui_only_funders.include?('Other'), false)
  end

  test 'valid with uri handle' do
    sub = submissions(:sub_one)
    sub.handle = 'http://example.com/123456/789.0'
    assert sub.valid?
  end

  test 'invalid with non nil blank handle' do
    sub = submissions(:sub_one)
    sub.handle = ''
    assert_not sub.valid?
  end

  test 'invalid with non uri handle' do
    sub = submissions(:sub_one)
    sub.handle = 'not a uri'
    assert_not sub.valid?
  end

  test 'uuid is set' do
    # fixtures bypass callbacks, so this is all manual.
    user = users(:one)
    sub = Submission.create(title: 'manual sub', documents: ['b_pdf.pdf'],
                            user: user, funders: ['Department of Energy (DOE)'],
                            publication_year: 1.year.ago.strftime('%Y'),
                            publication_month: 1.year.ago.strftime('%B'))
    assert(sub.uuid)
  end

  test '#mets' do
    Dir.chdir("#{Rails.root}/test/fixtures/schemas") do
      sub = submissions(:sub_two)
      xsd = Nokogiri::XML::Schema(File.read('mets.xsd'))
      doc = Nokogiri::XML(sub.to_mets('http://example.com/callback'))
      assert_equal(true, xsd.valid?(doc))
    end
  end

  test '#sword_package_name' do
    sub = submissions(:sub_one)
    assert_equal(sub.sword_path, 'tmp/69b9156a124c96bbdb55cad753810e14.zip')
  end

  def setup_sword_files(sub)
    FileUtils.rm_f(sub.sword_path)
    FileUtils.mkdir_p('./tmp/uploads/submission/documents/783478147')
    FileUtils.cp(['./test/fixtures/a_pdf.pdf', './test/fixtures/b_pdf.pdf'],
                 './tmp/uploads/submission/documents/783478147')
  end

  def cleaup_sword_files(sub)
    FileUtils.rm_f(sub.sword_path)
  end

  test '#to_sword_package creates zip file' do
    VCR.use_cassette('read a and b files from s3') do
      sub = submissions(:sub_one)
      setup_sword_files(sub)
      sub.to_sword_package('http://example.com/callback')
      assert_equal(true, File.file?(sub.sword_path))
      cleaup_sword_files(sub)
    end
  end

  test '#to_sword_package zip contains correct files' do
    VCR.use_cassette('read a and b files from s3') do
      sub = submissions(:sub_one)
      setup_sword_files(sub)
      sub.to_sword_package('http://example.com/callback')
      sword = Zip::File.open(sub.sword_path)
      assert_equal(['a_pdf.pdf', 'b_pdf.pdf', 'mets.xml'],
                   sword.map(&:name).sort)
      cleaup_sword_files(sub)
    end
  end

  test 'send_status_email will not send without a status' do
    sub = submissions(:sub_one)
    assert_difference('ActionMailer::Base.deliveries.size', 0) do
      sub.send_status_email
    end
  end

  test 'send_status_email with deposited status' do
    sub = submissions(:sub_one)
    sub.status = 'deposited'
    sub.save!
    assert_difference('ActionMailer::Base.deliveries.size', 1) do
      sub.send_status_email
    end
  end

  test 'send_status_email with approved status' do
    sub = submissions(:sub_one)
    sub.status = 'approved'
    sub.handle = 'http://example.com/123/456'
    sub.save!
    assert_difference('ActionMailer::Base.deliveries.size', 1) do
      sub.send_status_email
    end
  end

  test 'send_status_email with in review queue status' do
    sub = submissions(:sub_one)
    sub.status = 'in review queue'
    sub.save!
    assert_difference('ActionMailer::Base.deliveries.size', 1) do
      sub.send_status_email
    end
  end

  test 'send_status_email with rejected status' do
    sub = submissions(:sub_one)
    sub.status = 'rejected'
    sub.save!
    assert_difference('ActionMailer::Base.deliveries.size', 1) do
      sub.send_status_email
    end
  end

  test 'document_uri with non-localhost' do
    sub = submissions(:sub_one)
    assert_equal(sub.document_uri('//bucket.example.com/popcorn'),
                 'https://bucket.example.com/popcorn')
  end

  test 'document_uri with localhost' do
    sub = submissions(:sub_one)
    assert_equal(sub.document_uri('//localhost/popcorn'),
                 'http://localhost:10001/testbucket/popcorn')
  end

  test 'document_uri with spaces' do
    sub = submissions(:sub_one)
    assert_equal(sub.document_uri('//localhost/popcorn says'),
                 'http://localhost:10001/testbucket/popcorn%20says')
  end
end
