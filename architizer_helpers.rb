require 'open-uri'

module ArchitizerHelpers

  STOP_WORDS = ["Architecture" "Architects" "Architekten" "Architectes" "architect" "LLP" "Associates" "Arhitekti" "arquitectura" "Arkitekter" "Arquitectos" "Arquitecto" "Architekti" "&" "and" ","]

  def is_stop_word?(word)
    STOP_WORDS.any? { |w| word.match %r{#{w}}i }
  end

  def architizer_queryify(string)
    URI::escape(string.gsub('&', ''))
  end
end
