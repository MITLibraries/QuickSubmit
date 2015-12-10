require 'test_helper'

class SwordTest < ActiveSupport::TestCase
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

  test 'successful workflow submission' do
    VCR.use_cassette('workflow submission', preserve_exact_body_bytes: true) do
      sub = submissions(:sub_one)
      setup_sword_files(sub)
      sub.to_sword_package
      sword = Sword.new(sub)
      response = sword.deposit
      cleaup_sword_files(sub)
      assert_equal(response.code, 202)
    end
  end

  test 'successful deposited submission' do
    VCR.use_cassette('deposit', preserve_exact_body_bytes: true) do
      sub = submissions(:sub_one)
      setup_sword_files(sub)
      sub.to_sword_package
      sword = Sword.new(sub)
      response = sword.deposit
      cleaup_sword_files(sub)
      assert_equal(response.code, 201)
    end
  end

  test 'invalid credentials' do
    VCR.use_cassette('invalid credentials', preserve_exact_body_bytes: true) do
      sub = submissions(:sub_one)
      setup_sword_files(sub)
      sub.to_sword_package
      sword = Sword.new(sub)
      assert_raises RestClient::Unauthorized do
        sword.deposit
      end
      cleaup_sword_files(sub)
    end
  end
end
