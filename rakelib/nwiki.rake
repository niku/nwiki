namespace :nwiki do
  temporary_path = ENV.fetch("NWIKI_TEMPORARY_PATH", "tmp")

  desc "get head of a remote git repository"
  task :get_head do
    require "rugged"
    if File.exist?(temporary_path)
      repository = Rugged::Repository.discover(temporary_path)
      repository.fetch("origin")
      repository.reset("FETCH_HEAD", :hard)
    else
      Rugged::Repository.clone_at(ENV.fetch("NWIKI_REPO"), temporary_path)
    end
  end

  desc "convert from org to html"
  task :convert do
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
