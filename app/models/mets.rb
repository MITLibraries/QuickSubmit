class Mets
  def initialize(submission)
    @submission = submission
    @builder = Nokogiri::XML::Builder.new do |xml|
      xml['mets'].mets(
        'xmlns:mets' => 'http://www.loc.gov/METS/',
        'xmlns:xlink' => 'http://www.w3.org/1999/xlink',
        'xmlns:epdcx' => 'http://purl.org/eprint/epdcx/2006-11-16/') do
        overall_structure(xml)
      end
    end
  end

  def to_xml
    @builder.to_xml
  end

  private

  def overall_structure(xml)
    header(xml)
    dmd(xml)
    filesec(xml)
    structmap(xml)
  end

  def header(xml)
    xml['mets'].metsHdr('CREATEDATE' => '2009-02-12T08:35:13.561-05:00') do
      xml['mets'].agent('ROLE' => 'DISSEMINATOR',
                        'TYPE' => 'ORGANIZATION') do
        xml['mets'].name('MIT Libraries: QuickSubmit')
      end
    end
  end

  def dmd(xml)
    xml['mets'].dmdSec('ID' => 'VAA4025-102-1-a01-dmd') do
      xml['mets'].mdWrap('MDTYPE' => 'OTHER', 'OTHERMDTYPE' => 'EPDCX',
                         'MIMETYPE' => 'text/xml') do
        xml_data(xml)
      end
    end
  end

  def filesec(xml)
    xml['mets'].fileSec('ID' => 'VAA4025-102-1-a02-dmd') do
      xml['mets'].fileGrp('USE' => 'CONTENT') do
        xml['mets'].file('ID' => 'JHEP09',
                         'MIMETYPE' => 'application/pdf') do
          xml['mets'].FLocat('LOCTYPE' => 'URL',
                             'xlink:href' => 'JHEP09(2015)175_pdfa.pdf')
        end
      end
    end
  end

  def structmap(xml)
    xml['mets'].structMap('ID' => 'VAA4025-102-1-a03-dmd') do
      xml['mets'].div('DMDID' => 'sword-mets-dmd-1') do
        xml['mets'].div('TYPE' => 'File') do
          xml['mets'].fptr('FILEID' => 'JHEP09')
        end
      end
    end
  end

  def xml_data(xml)
    Epdcx.new(xml, @submission)
  end
end
