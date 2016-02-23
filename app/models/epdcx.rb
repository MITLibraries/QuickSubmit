class Epdcx
  def initialize(xml, submission, callback_uri)
    @xml = xml
    @callback_uri = callback_uri
    @xml['epdcx'].descriptionSet(
      'xmlns:epdcx' => 'http://purl.org/eprint/epdcx/2006-11-16/') do
      work(submission)
      entity(submission)
    end
  end

  def to_xml
    @xml.to_xml
  end

  private

  def entity(submission)
    @xml['epdcx'].description('epdcx:resourceId' => 'sword-mets-expr-1') do
      expression
      lang
      journal_article
      statement('http://purl.org/eprint/terms/bibliographicCitation',
                submission.journal) if submission.journal.present?
      doi(submission)
      pub_date(submission)
      funders(submission)
    end
  end

  def work(submission)
    @xml['epdcx'].description('epdcx:resourceId' => 'sword-mets-epdcx-1') do
      statement('http://libraries.mit.edu/xmlns/callback', @callback_uri)
      scholarly_work
      statement('http://purl.org/dc/elements/1.1/title', submission.title)

      @xml['epdcx'].statement('epdcx:propertyURI' =>
                             'http://purl.org/eprint/terms/isExpressedAs',
                              'epdcx:valueRef' => 'sword-mets-expr-1')
    end
  end

  def doi(submission)
    return unless submission.doi.present?
    @xml['epdcx'].statement('epdcx:propertyURI' =>
                            'http://purl.org/dc/elements/1.1/identifier') do
      @xml['epdcx'].valueString('epdcx:sesURI' =>
                                'http://purl.org/dc/terms/URI') do
        @xml.text(submission.doi)
      end
    end
  end

  def expression
    @xml['epdcx'].statement('epdcx:propertyURI' =>
                            'http://purl.org/dc/elements/1.1/type',
                            'epdcx:valueURI' =>
                            'http://purl.org/eprint/entityType/Expression')
  end

  def funders(submission)
    return unless submission.funders.present?
    submission.funders.each do |funder|
      statement('http://libraries.mit.edu/xmlns/sponsor', funder)
    end
  end

  def journal_article
    @xml['epdcx'].statement('epdcx:propertyURI' =>
                            'http://purl.org/dc/elements/1.1/type',
                            'epdcx:vesURI' =>
                            'http://purl.org/eprint/terms/Type',
                            'epdcx:valueURI' =>
                            'http://purl.org/eprint/type/JournalArticle')
  end

  def lang
    @xml['epdcx'].statement('epdcx:propertyURI' =>
                            'http://purl.org/dc/elements/1.1/language',
                            'epdcx:vesURI' =>
                            'http://purl.org/dc/terms/RFC3066') do
      @xml['epdcx'].valueString('en')
    end
  end

  def pub_date(submission)
    return unless submission.pub_date.present?
    statement('http://purl.org/dc/terms/available',
              submission.pub_date.strftime('%Y-%m'))
  end

  def scholarly_work
    @xml['epdcx'].statement('epdcx:propertyURI' =>
                            'http://purl.org/dc/elements/1.1/type',
                            'epdcx:valueURI' =>
                            'http://purl.org/eprint/entityType/ScholarlyWork')
  end

  def statement(prop_uri, value)
    @xml['epdcx'].statement('epdcx:propertyURI' => prop_uri) do
      @xml['epdcx'].valueString(value)
    end
  end
end
