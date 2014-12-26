# encoding: utf-8
module TruncateHtml
  class HtmlString < String

    UNPAIRED_TAGS = %w(br hr img).freeze
    REGEX = %r{
      (?:<script.*>.*<\/script>)+ # Match script tags. They aren't counted in length.
      |
      <\/?[^>]+> # Match html tags
      |
      \s+ # Match consecutive spaces. They are later truncated to a single space.
      |
      # [[:alpha]] - Match unicode alphabetical characters
      # \p{Sc} - Match unicode currency characters
      # \p{So} - Match unicode other symbols
      # [\p{Sm}&&[^<]] - Match unicode math characters except ASCII <. < opens html tags.
      # [\p{Zs}&&[^\s]] - Match unicode space characters except \s+. We truncate consecutive normal spaces.
      # [0-9]\|`~!@#\$%^&*\(\)\-_\+=\[\]{}:;'²³§",\.\/? - Match digits, few more characters
      # [[:punct]] - Don't gobble up chinese punctuation characters
      #
      # Refer to ruby's regex docs (http://www.ruby-doc.org/core-1.9.3/Regexp.html) for more info
      [[[:alpha:]]\p{Sc}\p{So}[\p{Sm}&&[^<]][\p{Zs}&&[^\s]][0-9]\|`~!@#\$%^&*\(\)\-_\+=\[\]{}:;'²³§",\.\/?[[:punct:]]]+ # Match tag body
    }x.freeze

    def initialize(original_html)
      super(original_html)
    end

    def html_tokens
      scan(REGEX).map do |token|
        HtmlString.new(
          token.gsub(
            /\n/,' ' #replace newline characters with a whitespace
          ).gsub(
            /\s+/, ' ' #clean out extra consecutive whitespace
          )
        )
      end
    end

    def html_tag?
      /<\/?[^>]+>/ === self && !html_comment?
    end

    def open_tag?
      /<(?!(?:#{UNPAIRED_TAGS.join('|')}|script|\/))[^>]+>/i === self
    end

    def html_comment?
      /<\s?!--.*-->/ === self
    end

    def matching_close_tag
      gsub(/<(\w+)\s?.*>/, '</\1>').strip
    end

  end
end
