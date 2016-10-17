require 'angular-rails-templates/compact_javascript_escape'

module AngularRailsTemplates
  class Template < ::Tilt::Template
    include CompactJavaScriptEscape
    AngularJsTemplateWrapper = Tilt::ERBTemplate.new "#{File.dirname __FILE__}/javascript_template.js.erb"
    @@compressor = nil

    def self.default_mime_type
      'application/javascript'
    end

    def prepare
      # we only want to process html assets inside those specified in configuration.inside_paths
      @asset_should_be_processed = configuration.inside_paths.any? { |folder| file.match(folder.to_s) }

      if configuration.htmlcompressor and @asset_should_be_processed
        @data = compress data
      end
    end

    def evaluate(scope, locals, &block)
      locals[:html] = escape_javascript data.chomp
      locals[:angular_template_name] = logical_template_path(scope)
      locals[:source_file] = "#{scope.pathname}".sub(/^#{Rails.root}\//,'')
      locals[:angular_module] = configuration.module_name

      if @asset_should_be_processed
        AngularJsTemplateWrapper.render(scope, locals)
      else
        data
      end
    end

    private

    def logical_template_path(scope)
      path = scope.logical_path.sub /^(#{configuration.ignore_prefix.join('|')})/, ''
      "#{path}.html"
    end

    def configuration
      ::Rails.configuration.angular_templates
    end

    def compress html
      unless @@compressor
        @@compressor = HtmlCompressor::Compressor.new configuration.htmlcompressor
      end
      @@compressor.compress(html)
    end
  end
end

