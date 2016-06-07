namespace :nwiki do
  temporary_path = ENV.fetch("NWIKI_TEMPORARY_PATH", "tmp")

  desc "clone a git repository via network"
  task :clone do
    require "rugged"
    Rugged::Repository.clone_at(ENV.fetch("NWIKI_REPO"), temporary_path)
  end

  desc "convert from org to html"
  task convert: :clone do
    require "org-ruby"
    FileList.new("#{temporary_path}/**/*.org").each do |path|
      new_path = File.join(File.dirname(path), File.basename(path, ".org") + ".html")
      doc = File.read(path)
      html = Orgmode::Parser.new(doc).to_html
      File.write(new_path, html)
      File.delete(path)
    end
  end
end
