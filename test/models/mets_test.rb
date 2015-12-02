require 'test_helper'

class MetsTest < ActiveSupport::TestCase
  test 'initializing with a full submission creates valid mets xml' do
    Dir.chdir("#{Rails.root}/test/fixtures/schemas") do
      sub = submissions(:sub_two)
      xsd = Nokogiri::XML::Schema(File.read('mets.xsd'))
      xml = Mets.new(sub).to_xml
      doc = Nokogiri::XML(xml)
      assert_equal(true, xsd.valid?(doc))
    end
  end

  test 'initializing with a sparse submission creates valid mets xml' do
    Dir.chdir("#{Rails.root}/test/fixtures/schemas") do
      sub = submissions(:sub_one)
      xsd = Nokogiri::XML::Schema(File.read('mets.xsd'))
      xml = Mets.new(sub).to_xml
      doc = Nokogiri::XML(xml)
      assert_equal(true, xsd.valid?(doc))
    end
  end
end
