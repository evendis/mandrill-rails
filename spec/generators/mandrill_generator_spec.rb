require 'spec_helper'
require 'generator_spec'
require 'generators/mandrill/mandrill_generator'

describe Mandrill::Rails::Generators::MandrillGenerator, type: :generator do
  destination File.expand_path("../../tmp", __FILE__)

  before do
    prepare_destination
    copy_routes
  end

  describe 'route generation' do
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

  describe 'controller generation' do
    context 'with controller explicitly skipped' do
      before { run_generator %w(inbox --skip-controller) }

      it 'does not create a controller file' do
        expect(destination_root).to have_structure {
          directory 'app' do
            directory 'controllers' do
              no_file 'inbox_controller.rb'
            end
          end
        }
      end
    end

    context 'with no pluralized option' do
      context 'with simple names' do
        before { run_generator %w(inbox) }

        it 'creates a proper controller file' do
          match = 'class InboxController < ApplicationController'
          expect(destination_root).to have_structure {
            directory 'app' do
              directory 'controllers' do
                file 'inbox_controller.rb' do
                  contains match
                end
              end
            end
          }
        end
      end

      context 'with namespaced names' do
        before { run_generator %w(hooks/inbox) }

        it 'creates a proper controller file' do
          match = 'class Hooks::InboxController < ApplicationController'
          expect(destination_root).to have_structure {
            directory 'app' do
              directory 'controllers' do
                directory 'hooks' do
                  file 'inbox_controller.rb' do
                    contains match
                  end
                end
              end
            end
          }
        end
      end

      context 'with capitalized names' do
        before { run_generator %w(hooks/Inbox) }

        it 'creates a proper controller file' do
          match = 'class Hooks::InboxController < ApplicationController'
          expect(destination_root).to have_structure {
            directory 'app' do
              directory 'controllers' do
                directory 'hooks' do
                  file 'inbox_controller.rb' do
                    contains match
                  end
                end
              end
            end
          }
        end
      end
    end

    context 'with an explicit pluralized option' do
      context 'with simple names' do
        before { run_generator %w(inbox --pluralize_names) }

        it 'creates a proper controller file' do
          match = 'class InboxesController < ApplicationController'
          expect(destination_root).to have_structure {
            directory 'app' do
              directory 'controllers' do
                file 'inboxes_controller.rb' do
                  contains match
                end
              end
            end
          }
        end
      end

      context 'with namespaced names' do
        before { run_generator %w(hooks/inbox --pluralize_names) }

        it 'creates a proper controller file' do
          match = 'class Hooks::InboxesController < ApplicationController'
          expect(destination_root).to have_structure {
            directory 'app' do
              directory 'controllers' do
                directory 'hooks' do
                  file 'inboxes_controller.rb' do
                    contains match
                  end
                end
              end
            end
          }
        end
      end

      context 'with capitalized names' do
        before { run_generator %w(hooks/Inboxes --pluralized_names) }

        it 'creates a proper controller file' do
          match = 'class Hooks::InboxesController < ApplicationController'
          expect(destination_root).to have_structure {
            directory 'app' do
              directory 'controllers' do
                directory 'hooks' do
                  file 'inboxes_controller.rb' do
                    contains match
                  end
                end
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
