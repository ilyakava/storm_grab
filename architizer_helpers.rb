require 'open-uri'

module ArchitizerHelpers
  def architizer_queryify(string)
    URI::escape(string.gsub('&', ''))
  end
end
