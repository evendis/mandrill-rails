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

  module ClassMethods
    # Returns the current WebHook key(s) as an Array if called with no parameters.
    # If called with parameters, add the params to the WebHook key array.
    # If called with nil as the parameters, clears the WebHook key array.
    def mandrill_webhook_keys(*keys)
      @mandrill_webhook_keys ||= []
      if keys.present?
        if keys.compact.present?
          @mandrill_webhook_keys.concat(keys.flatten)
        else
          @mandrill_webhook_keys = []
        end
      end
      @mandrill_webhook_keys
    end

    # Command: directly assigns the WebHook key array to +keys+
    def mandrill_webhook_keys=(keys)
      @mandrill_webhook_keys = Array(keys)
    end

  end

  # Handles controller :show action (corresponds to a Mandrill "are you there?" test ping).
  # Returns 200 and does nothing else.
  def show
    head(:ok)
  end

  # Handles controller :create action (corresponds to a POST from Mandrill).
  def create
    processor = Mandrill::WebHook::Processor.new(params, self)
    processor.run!
    head(:ok)
  end

  def authenticate_mandrill_request!
  	if request.post?
  	  unless Mandrill::WebHook::Processor.new(params, self).authentic?(request)
  	    head(:forbidden, :text => "Mandrill signature did not match.")
  	    return false
  	  end
  	end
  end

end
