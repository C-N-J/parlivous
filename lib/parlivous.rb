require 'parlivous/version'
require 'redcarpet'
require 'parlivous/renderers/article'
require 'parlivous/rendered'
require 'parlivous/renderers/table_of_contents'
require 'parlivous/renderers/article/table_of_contents'

module Parlivous
  def self.render(renderer, text, options = {})
    add_toc_data_to_options(options) if options[:table_of_contents]
    # Allow the use of the default Redcarpet renderer
    return Redcarpet::Markdown.new(renderer, options).render(text) if renderer.to_s.split('::')[0] == 'Redcarpet'
    raise ArgumentError, "#{renderer} is not a valid renderer." unless Parlivous::Renderers.constants.include?(renderer.to_sym)

    renderer_const = Object.const_get("Parlivous::Renderers::#{renderer}")

    rendered_markdown = Parlivous::Rendered.new
    rendered_markdown.html = Redcarpet::Markdown.new(renderer_const, options).render(text)

    # Check if there's a specific TOC renderer for the one passed otherwise use the default
    if options[:table_of_contents]
      custom_table_of_contents_renderer_exists = renderer_const.constants.include?(:TableOfContents)
      rendered_markdown.table_of_contents = Redcarpet::Markdown.new(
        custom_table_of_contents_renderer_exists ? renderer_const::TableOfContents : Parlivous::Renderers::TableOfContents,
        options
      ).render(text)
    end

    rendered_markdown
  end

  # Add Recarpet option to add anchors to the body if table_of_contents is passed in
  def self.add_toc_data_to_options(options)
    options[:with_toc_data] = true
  end
end
