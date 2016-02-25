require 'test_helper'

class EpdcxTest < ActiveSupport::TestCase
  test 'initializing with a full submission creates valid epdcx xml' do
    Dir.chdir("#{Rails.root}/test/fixtures/schemas") do
      sub = submissions(:sub_two)
      sub.pub_date = Time.current
      builder = Nokogiri::XML::Builder.new { |xml| xml }
      xsd = Nokogiri::XML::Schema(File.read('epdcx.xsd'))
      xml = Epdcx.new(builder, sub, 'http://example.com').to_xml
      doc = Nokogiri::XML(xml)
      assert_equal(true, xsd.valid?(doc))
    end
  end

  test 'initializing with a sparse submission creates valid epdcx xml' do
    Dir.chdir("#{Rails.root}/test/fixtures/schemas") do
      sub = submissions(:sub_one)
      builder = Nokogiri::XML::Builder.new { |xml| xml }
      xsd = Nokogiri::XML::Schema(File.read('epdcx.xsd'))
      xml = Epdcx.new(builder, sub, 'http://example.com').to_xml
      doc = Nokogiri::XML(xml)
      assert_equal(true, xsd.valid?(doc))
    end
  end
end
