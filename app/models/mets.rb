# A METS XML document for a Submission
class Mets
  # Creates a METS XML document for a Submission
  #
  # @param submission [Submission]
  # @param callback_uri
  #   Text based representation of a URI the will be included
  #   in the mets.xml document that a remote server can use to communicate back
  #   with a status update for the Submission
  # @see Submission
  # @see Epdcx
  def initialize(submission, callback_uri)
    @submission = submission
    @callback_uri = callback_uri
    @builder = xml_builder
  end

  # Converts the built Nokogiri Document into standard xml
  def to_xml
    @builder.to_xml
  end

  private

  def xml_builder
    Nokogiri::XML::Builder.new do |xml|
      xml['mets'].mets(
        'xmlns:mets' => 'http://www.loc.gov/METS/',
        'xmlns:xlink' => 'http://www.w3.org/1999/xlink',
        'xmlns:epdcx' => 'http://purl.org/eprint/epdcx/2006-11-16/',
        'PROFILE' => 'DSpace METS SIP Profile 1.0') do
        overall_structure(xml)
      end
    end
  end

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
    xml['mets'].dmdSec('ID' => 'mitqs_dmd') do
      xml['mets'].mdWrap('MDTYPE' => 'OTHER', 'OTHERMDTYPE' => 'EPDCX',
                         'MIMETYPE' => 'text/xml') do
        xml_data(xml)
      end
    end
  end

  def filegrp(xml, doc, index)
    xml['mets'].fileGrp('USE' => 'CONTENT') do
      xml['mets'].file('ID' => "mitqs_doc_#{index}",
                       'MIMETYPE' => 'application/pdf') do
        xml['mets'].FLocat('LOCTYPE' => 'URL',
                           'xlink:href' => doc.split('/').last)
      end
    end
  end

  def filesec(xml)
    xml['mets'].fileSec do
      @submission.documents.each_with_index do |doc, index|
        filegrp(xml, doc, index)
      end
    end
  end

  def structmap(xml)
    xml['mets'].structMap do
      xml['mets'].div('DMDID' => 'mitqs_dmd') do
        xml['mets'].div('TYPE' => 'File') do
          @submission.documents.each_with_index do |_doc, index|
            xml['mets'].fptr('FILEID' => "mitqs_doc_#{index}")
          end
        end
      end
    end
  end

  def xml_data(xml)
    xml['mets'].xmlData do
      Epdcx.new(xml, @submission, @callback_uri)
    end
  end
end
