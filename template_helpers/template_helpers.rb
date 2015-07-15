module TemplateHelpers
  def indent_file(file, by:)
    gsub_file file, /^/, (['  '] * by).join
  end
end
