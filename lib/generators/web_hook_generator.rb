require 'rails/generators/named_base'

module Mandrill
  module Rails
    module Generators
      class WebHookGenerator < ::Rails::Generators::Base
        namespace 'mandrill'
        argument :name, type: :string
        class_option :pluralize_names, type: :boolean, default: false,
                                    desc: 'Pluralize names in route and controller'

        source_root File.expand_path("../templates", __FILE__)

        desc 'Generates a controller and routes for Mandrill webhooks.'

        def initialize(args, *options)
          args[0] = args[0].dup if args[0].is_a?(String) && args[0].frozen?
          super
          assign_names!(self.name)
        end

        def add_routes
          hook_route = "resource :#{resource_name}"

          controller = controller_path

          hook_route << %Q(, :controller => '#{controller}')
          hook_route << %Q(, :only => [:show,:create])
          route hook_route
        end
    
      private

        attr_reader :file_name

        def assign_names!(name)
          @class_path = name.include?('/') ? name.split('/') : name.split('::')
          @class_path.map!(&:underscore)
          @file_name = @class_path.pop
        end

        def class_name
          @class_name ||= (@class_path + [file_name]).map!(&:camelize).join('::')
        end

        def controller_path
          @controller_path ||= if class_name.include?('::')
            @class_path.collect {|dname| dname }.join + "/" + resource_name
          else
            resource_name
          end
        end

        def plural_name
          @plural_name ||= singular_name.pluralize
        end

        def resource_name
          return singular_name unless options.pluralize_names?
          plural_name
        end

        def singular_name
          file_name.downcase
        end
      end
    end
  end
end
