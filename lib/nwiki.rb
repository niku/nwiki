require "nwiki/version"

module Nwiki
  class << self
    def get_head(temporary_path, repo_url)
      require "rugged"
      if File.exist?(temporary_path)
        repository = Rugged::Repository.discover(temporary_path)
        repository.fetch("origin")
        repository.reset("FETCH_HEAD", :hard)
      else
        Rugged::Repository.clone_at(repo_url, temporary_path)
      end
    end

    def convert(temporary_path)
      require "org-ruby"
      FileList.new("#{temporary_path}/**/*.org").each do |path|
        new_path = File.join(File.dirname(path), File.basename(path, ".org") + ".html.contents")
        doc = File.read(path)
        html = Orgmode::Parser.new(doc, allow_include_files: true).to_html
        File.write(new_path, html)
        File.delete(path)
      end
    end
  end
end
