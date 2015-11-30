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

  test '#mets' do
    Dir.chdir("#{Rails.root}/test/fixtures/schemas") do
      sub = submissions(:sub_two)
      xsd = Nokogiri::XML::Schema(File.read('mets.xsd'))
      doc = Nokogiri::XML(sub.to_mets)
      assert_equal(true, xsd.valid?(doc))
    end
  end
end
