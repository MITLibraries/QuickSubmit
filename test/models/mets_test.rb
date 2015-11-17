require 'test_helper'

class MetsTest < ActiveSupport::TestCase
  test 'initializing with a full submission creates valid mets xml' do
    VCR.use_cassette('mets_dtd') do
      dtd = Net::HTTP.get(URI('http://www.loc.gov/standards/mets/version111/mets.xsd'))
      sub = submissions(:sub_two)
      xsd = Nokogiri::XML::Schema(dtd)
      xml = Mets.new(sub).to_xml
      doc = Nokogiri::XML(xml)
      assert_equal(true, xsd.valid?(doc))
    end
  end

  test 'initializing with a sparse submission creates valid mets xml' do
    VCR.use_cassette('mets_dtd') do
      dtd = Net::HTTP.get(URI('http://www.loc.gov/standards/mets/version111/mets.xsd'))
      sub = submissions(:sub_one)
      xsd = Nokogiri::XML::Schema(dtd)
      xml = Mets.new(sub).to_xml
      doc = Nokogiri::XML(xml)
      assert_equal(true, xsd.valid?(doc))
    end
  end
end
