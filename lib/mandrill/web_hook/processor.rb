class Mandrill::WebHook::Processor

  attr_accessor :mandrill_events, :callback_host

  # Command initialise the processor with +params+ Hash.
  # +params+ is expected to contain an array of mandrill_events
  def initialize(params={})
    @mandrill_events = JSON.parse(params['mandrill_events'] || '[]')
  end

  # Command: processes all +mandrill_events+
  def run!
    mandrill_events.each do |raw_payload|
      event_payload = wrap_payload(raw_payload)
      handler = "handle_#{event_payload.event_type}".to_sym
      if callback_host && callback_host.respond_to?(handler)
        callback_host.send(handler,event_payload)
      elsif self.respond_to?(handler)
        self.send(handler,event_payload)
      else
        # TODO raise an error
      end
    end
  end

  # Returns a suitably ecapsulated +raw_event_payload+
  def wrap_payload(raw_event_payload)
    Mandrill::WebHook::EventDecorator[raw_event_payload]
  end

end
