class Epdcx
  def initialize(xml, submission)
    @xml = xml
    @xml['mets'].xmlData do
      @xml['epdcx'].descriptionSet(
        'xmlns:epdcx' => 'http://purl.org/eprint/epdcx/2006-11-16/',
        'xsi:schemaLocation' =>
          'http://purl.org/eprint/epdcx/xsd/2006-11-16/epdcx.xsd') do
        work(submission)
        entity(submission)
      end
    end
  end

  private

  def entity(submission)
    @xml['epdcx'].description('epdcx:resourceId' => 'sword-mets-expr-1') do
      expression
      lang
      journal_article
      statement('http://purl.org/eprint/terms/bibliographicCitation',
                submission.journal)
      doi(submission)
    end
  end

  def work(submission)
    @xml['epdcx'].description('epdcx:resourceId' => 'sword-mets-epdcx-1') do
      scholarly_work
      statement('http://purl.org/dc/elements/1.1/title', submission.title)
      statement('http://purl.org/dc/elements/1.1/creator', submission.author)

      @xml['epdcx'].statement('epdcx:propertyURI' =>
                             'http://purl.org/eprint/terms/isExpressedAs') do
        @xml['epdcx'].valueRef('sword-mets-expr-1')
      end
    end
  end

  def doi(submission)
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
