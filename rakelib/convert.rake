require "org-ruby"

desc "convert from org to html"
namespace :nwiki do
  task convert: :clone do
    FileList.new("tmp/**/*.org").each do |path|
      new_path = File.join(File.dirname(path), File.basename(path, ".org") + ".html")
      doc = File.read(path)
      html = Orgmode::Parser.new(doc).to_html
      File.write(new_path, html)
      File.delete(path)
    end
  end
end
