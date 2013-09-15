class Mandrill::WebHook::Processor

  attr_accessor :params, :callback_host, :mandrill_events

  # Command initialise the processor with +params+ Hash.
  # +params+ is expected to contain an array of mandrill_events.
  # +callback_host+ is a handle to the controller making the request.
  def initialize(params={},callback_host=nil)
    @params = params
    @callback_host = callback_host
  end

  def mandrill_events
    @mandrill_events ||= JSON.parse(params['mandrill_events'] || '[]')
  rescue
    @mandrill_events = []
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

  # Returns true if +request+ does not require authentication, or when authentication is valid.
  def authentic?(request)
    result = true
    if callback_host && (keys = callback_host.class.mandrill_webhook_keys).present?
      expected_signature = callback_host.request.headers['HTTP_X_MANDRILL_SIGNATURE']
      keys.each do |key|
        signature = generate_signature(key, request.original_url, request.params)
        result = (signature == expected_signature)
        break if result
      end
    end
    result
  end

  # Method described in docs: http://help.mandrill.com/entries/23704122-Authenticating-webhook-requests
  def generate_signature(webhook_key, original_url, params)
    signed_data = original_url.dup
    params.except(:action, :controller).keys.sort.each do |key|
      signed_data << key
      signed_data << params[key]
    end
    Base64.encode64("#{OpenSSL::HMAC.digest('sha1', webhook_key, signed_data)}").strip
  end

end
