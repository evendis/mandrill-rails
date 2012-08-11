# WebHookProcessor is a module that mixes in Mandrill web hook processing support
# to a controller in your application.
#
# The controller is expected to be a singlular resource controller.
# WebHookProcessor provides the :show and :create method implementation.
#
# 1. Create a controller that includes Mandrill::Rails::WebHookProcessor
# 2. Direct a GET :show and POST :create route to the controller
# 3. Define handlers for each of the event types you want to handle
#
# e.g. in routes.rb:
#
#   resource :webhook, :controller => 'webhook', :only => [:show,:create]
#
# e.g. a Webhook controller:
#
#   class WebhookController < ApplicationController
#     include Mandrill::Rails::WebHookProcessor
#
#     # Command: handle each 'inbound' +event_payload+ from Mandrill
#     def handle_inbound(event_payload)
#       # do some stuff
#     end
#
#     # Define other handlers for each event type required.
#     # Possible event types: inbound, send, hard_bounce, soft_bounce, open, click, spam, unsub, or reject
#     # def handle_<event_type>(event_payload)
#     #   # do some stuff
#     # end
#
#   end
#
module Mandrill::Rails::WebHookProcessor
  extend ActiveSupport::Concern

  included do
    skip_before_filter :verify_authenticity_token
  end

  # Returns 200 and does nothing else (this is a test done by the mandrill service)
  def show
    head(:ok)
  end

  def create
    if processor = Mandrill::WebHook::Processor.new(params)
      processor.callback_host = self
      processor.run!
    end
    head(:ok)
  end


end