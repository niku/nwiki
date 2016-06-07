namespace :nwiki do
  desc "clone a git repository via network"
  task :clone do
    require "rugged"
    Rugged::Repository.clone_at(ENV.fetch("NWIKI_REPO"), "tmp")
  end

  desc "convert from org to html"
  task convert: :clone do
    require "org-ruby"
    FileList.new("tmp/**/*.org").each do |path|
      new_path = File.join(File.dirname(path), File.basename(path, ".org") + ".html")
      doc = File.read(path)
      html = Orgmode::Parser.new(doc).to_html
      File.write(new_path, html)
      File.delete(path)
    end
  end
end
