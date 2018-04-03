RSpec.describe Parlivous do
  it "has a version number" do
    expect(Parlivous::VERSION).not_to be nil
  end

  context '#render' do
    context 'passed correct arguments' do
      let(:raw_markdown){ File.read('spec/fixtures/articles/markdown') }
      let(:converted_markdown){ File.read('spec/fixtures/articles/rendered/html') }
      let(:converted_table_of_contents){ File.read('spec/fixtures/rendered/table_of_contents') }
      let(:converted_article_table_of_contents){ File.read('spec/fixtures/articles/rendered/table_of_contents') }

      it' will return a Parlivous::Rendered object' do
        expect(described_class.render('Article', raw_markdown, {}).class).to eq(Parlivous::Rendered)
      end

      it 'will return converted markdown' do
        expect(described_class.render('Article', raw_markdown, {}).html).to eq(converted_markdown)
      end

      context 'table of contents' do
        let(:options){ { table_of_contents: true } }

        it 'will add \'with_toc_data\' to options' do
          described_class.render(Redcarpet::Render::HTML_TOC, raw_markdown, options)
          expect(options.keys).to eq([:table_of_contents, :with_toc_data])
        end

        context 'did not pass in option' do
          let(:options){ {} }

          it 'will not add \'with_toc_data\' to options' do
            described_class.render(Redcarpet::Render::HTML, raw_markdown, options)
            expect(options).to eq({})
          end

          it 'will not render a table of contents' do
            expect(described_class.render('Article', raw_markdown, {}).table_of_contents).to eq(nil)
          end
        end

        context 'no custom table of contents' do
          context 'Redcarpet default' do
            it 'will render a default table of contents' do
              expect(described_class.render(Redcarpet::Render::HTML_TOC, raw_markdown, { table_of_contents: true })).to eq(converted_table_of_contents)
            end
          end

          context 'default for custom renderer' do
            let!(:mocked_renderer){ class Parlivous::Renderers::Book < Redcarpet::Render::HTML; end }

            it 'will render a default table of contents' do
              expect(described_class.render('Book', raw_markdown, { table_of_contents: true }).table_of_contents).to eq(converted_table_of_contents)
            end
          end
        end

        context 'custom table of contents' do
          it 'will render a custom table of contents' do
            pending('Requires a read time solution')
            expect(described_class.render('Article', raw_markdown, { table_of_contents: true }).table_of_contents).to eq(converted_article_table_of_contents)
          end
        end
      end

      context 'passed default Redcarpet renderer' do
        it 'will return converted markdown' do
          expect(described_class.render(Redcarpet::Render::HTML, raw_markdown, {})).to eq(converted_markdown)
        end

        it 'will not call Object#const_get' do
          expect(Object).not_to receive(:const_get)
          described_class.render(Redcarpet::Render::HTML, raw_markdown, {})
        end
      end
    end

    context 'passed incorrect renderer' do
      it' will raise an ArgumentError error' do
        expect{ described_class.render('InvalidRenderer', '# Test Markdown', {}) }.to raise_error(ArgumentError, 'InvalidRenderer is not a valid renderer.')
      end
    end
  end

  context '#add_toc_data_to_options' do
    let(:options){ {} }
    it 'will add toc data to options hash' do
      described_class.add_toc_data_to_options(options)
      expect(options).to eq({ with_toc_data: true })
    end
  end
end
