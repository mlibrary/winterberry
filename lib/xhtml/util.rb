module UMPTG::XHTML

  # Update reference path extension from .htm|.html to .xhtml.
  # Required for EPUB 3.x
  def self.fix_ext(path)
    path = path.nil? ? "" : path
    unless path.empty? or path.start_with?("http:") or path.include?("www.")
      slist = path.split('#')
      p = slist[0]
      suf = slist.count > 1 ? "#" + slist[1] : ""

      ext = File.extname(p)
      if [".htm", ".html", ".xml"].include?(ext)
        return File.join(File.dirname(p), File.basename(p, ".*") + ".xhtml" + suf)
      end
    end
    return path
  end
end
