class Sword
  attr_reader :response

  def initialize(submission, callback_uri)
    @submission = submission
    @callback_uri = callback_uri
    @sword_server = RestClient::Resource.new(
      Rails.application.secrets.sword_endpoint,
      user: Rails.application.secrets.sword_username,
      password: Rails.application.secrets.sword_password)
  end

  def deposit
    @submission.to_sword_package(@callback_uri)
    @response = @sword_server.post(
      File.read(@submission.sword_path),
      content_type: 'application/zip',
      x_packaging: 'http://purl.org/net/sword-types/METSDSpaceSIP')
  end

  def handle
    return unless @response.code == 201
    xml = Nokogiri::XML(@response)
    xml.xpath('//atom:id').text
  end
end
