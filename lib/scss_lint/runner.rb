require 'scss_lint'
require 'sass'

module SCSSLint
  class NoFilesError < StandardError; end
  class NoLintersError < StandardError; end

  class Runner
    attr_reader :linters, :lints

    def initialize(options = {})
      @lints = []

      ignored_linters = LinterRegistry.
        extract_linters_from(options.fetch(:ignored_linters, []))

      @linters = LinterRegistry.linters.reject do |linter|
        ignored_linters.include?(linter)
      end
    end

    def run(files = [])
      raise NoFilesError.new('No SCSS files specified') if files.empty?
      raise NoLintersError.new('No linters specified') if linters.empty?

      files.each do |file|
        find_lints(file)
      end
    end

    def find_lints(file)
      engine = Engine.new(file)

      linters.each do |linter|
        @lints += linter.run(engine)
      end
    rescue Sass::SyntaxError => ex
      @lints << Lint.new(ex.sass_filename, ex.sass_line, ex.to_s)
    end

    def lints?
      @lints.any?
    end
  end
end
