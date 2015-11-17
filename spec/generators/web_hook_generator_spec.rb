require 'spec_helper'
require 'generator_spec'
require 'generators/web_hook_generator'

describe Mandrill::Rails::Generators::WebHookGenerator, type: :generator do
  destination File.expand_path("../../tmp", __FILE__)

  before do
    prepare_destination
    copy_routes
  end

  describe 'route generation' do
    before { @route_path = "#{destination_root}/config/routes.rb" }

    context 'with no pluralized option' do
      context 'with simple names' do
        before { run_generator %w(inbox) }

        it 'creates a proper route' do
          match = "resource :inbox, :controller => 'inbox', :only => [:show,:create]"
          expect(destination_root).to have_structure {
            directory 'config' do
              file 'routes.rb' do
                contains match
              end
            end
          }
        end
      end

      context 'with namespaced names' do
        before { run_generator %w(hooks/inbox) }

        it 'creates a proper route' do
          match = "resource :inbox, :controller => 'hooks/inbox', :only => [:show,:create]"
          expect(destination_root).to have_structure {
            directory 'config' do
              file 'routes.rb' do
                contains match
              end
            end
          }
        end
      end

      context 'with capitalized names' do
        before { run_generator %w(Inbox) }

        it 'creates a proper route' do
          match = "resource :inbox, :controller => 'inbox', :only => [:show,:create]"
          expect(destination_root).to have_structure {
            directory 'config' do
              file 'routes.rb' do
                contains match
              end
            end
          }
        end
      end
    end

    context 'with an explicit pluralized option' do
      context 'with simple names' do
        before { run_generator %w(inbox --pluralize_names) }

        it 'creates a proper route' do
          match = "resource :inboxes, :controller => 'inboxes', :only => [:show,:create]"
          expect(destination_root).to have_structure {
            directory 'config' do
              file 'routes.rb' do
                contains match
              end
            end
          }
        end
      end

      context 'with namespaced names' do
        before { run_generator %w(hooks/inbox --pluralize_names) }

        it 'creates a proper route' do
          match = "resource :inboxes, :controller => 'hooks/inboxes', :only => [:show,:create]"
          expect(destination_root).to have_structure {
            directory 'config' do
              file 'routes.rb' do
                contains match
              end
            end
          }
        end
      end

      context 'with capitalized names' do
        before { run_generator %w(hooks/Inbox --pluralize_names) }

        it 'creates a proper route' do
          match = "resource :inboxes, :controller => 'hooks/inboxes', :only => [:show,:create]"
          expect(destination_root).to have_structure {
            directory 'config' do
              file 'routes.rb' do
                contains match
              end
            end
          }
        end
      end
    end
  end
end

def copy_routes
  routes = File.expand_path('../../rails_app/config/routes.rb', __FILE__)
  destination = File.join(destination_root, 'config')

  FileUtils.mkdir_p(destination)
  FileUtils.cp routes, destination
end
