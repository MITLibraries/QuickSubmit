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

  test 'invalid without agreed_to_license' do
    sub = submissions(:sub_one)
    sub.agreed_to_license = false
    assert_not sub.valid?
  end

  test 'invalid without documents' do
    sub = submissions(:sub_one)
    sub.remove_documents!
    assert_not sub.valid?
  end

  test '#mets' do
    Dir.chdir("#{Rails.root}/test/fixtures/schemas") do
      sub = submissions(:sub_two)
      xsd = Nokogiri::XML::Schema(File.read('mets.xsd'))
      doc = Nokogiri::XML(sub.to_mets)
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
    sub.documents.map(&:remove!)
    FileUtils.rm_f(sub.sword_path)
  end

  test '#to_sword_package creates zip file' do
    sub = submissions(:sub_one)
    setup_sword_files(sub)
    sub.to_sword_package
    assert_equal(true, File.file?(sub.sword_path))
    cleaup_sword_files(sub)
  end

  test '#to_sword_package zip contains correct files' do
    sub = submissions(:sub_one)
    setup_sword_files(sub)
    sub.to_sword_package
    sword = Zip::File.open(sub.sword_path)
    assert_equal(['a_pdf.pdf', 'b_pdf.pdf', 'mets.xml'], sword.map(&:name).sort)
    cleaup_sword_files(sub)
  end
end
