require 'open-uri'

module ArchitizerHelpers

  STOP_WORDS = %w{Architecture Architects Architekten Architectes architect LLP Associates Arhitekti arquitectura Arkitekter Arquitectos Arquitecto Architekti & and , \+ Associates} 

  def is_stop_word?(word)
    STOP_WORDS.any? { |w| word.match %r{#{w}}i }
  end

  def remove_bad_chars(string)
    string.gsub(/[^A-Za-z1-9\s]/, "")
  end

  def architizer_queryify(string)
    URI::escape(remove_bad_chars(string))
  end

  def ensure_utf8(arg)
    if arg.is_a?(Array)
      arg.map { |e| ensure_utf8(e) }
    elsif arg.is_a?(String)
      arg.dup.force_encoding(Encoding.find("UTF-8"))
    else
      arg
    end
  end
end
