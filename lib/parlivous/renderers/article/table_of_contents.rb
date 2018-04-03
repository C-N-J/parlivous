module Parlivous
  module Renderers
    class Article
      class TableOfContents < Redcarpet::Render::HTML_TOC
        def postprocess(text)
          text.gsub!('ul', 'ol')
        end
      end
    end
  end
end
