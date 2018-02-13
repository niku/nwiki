# frozen_string_literal: true

require "fileutils"
require_relative "config"
require_relative "html_fragment"
require_relative "html_metadata"
require_relative "html_metalink"
require_relative "path"
require_relative "page_builder"
require_relative "repository"
require_relative "root_index_builder"

module Nwiki
  class App
    def initialize(config, repository, output_directory)
      @config = config
      @repository = repository
      @output_directory = output_directory
    end

    def org_files
      @repository
        .files
        .select { |file| file.path.extname == ".org" }
        .map { |e| HtmlFragment.new(e) }
        .map { |e| HtmlMetadata.new(e) }
    end

    def raw_files
      @repository
        .files
        .select { |file| file.path.extname != ".org" }
    end

    def write_out_raw_files!
      raw_files.each do |page|
        Dir.chdir @output_directory do
          FileUtils.mkdir_p(page.path.dirname) unless page.path.dirname.empty?
          ::File.write(page.path.name, page.read)
        end
      end
    end

    def write_out_org_files!
      html_metalink = HtmlMetalink.new(org_files)
      pagebuilders = org_files.map { |org_file| PageBuilder.new(@config, org_file, html_metalink) }
      pagebuilders.each do |page|
        Dir.chdir @output_directory do
          FileUtils.mkdir_p(page.path.dirname) unless page.path.dirname.empty?
          ::File.write(PageBuilder.org_url_to_html(page.path.name), page.read)
        end
      end
    end

    def write_out_root_index_file!
      root_index = RootIndexBuilder.new(@config, org_files)
      Dir.chdir @output_directory do
        ::File.write(root_index.path, root_index.data)
      end
    end

    def run
      write_out_raw_files!
      write_out_org_files!
      write_out_root_index_file!
    end
  end
end
