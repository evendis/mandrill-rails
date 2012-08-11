# Wraps an individual Mandrill web hook event payload,
# providing some convenience methods handling the payload.
#
# Given a raw event payload Hash, wrap it thus:
#
#   JSON.parse(params['mandrill_events']).each do |raw_event|
#     event = Mandrill::WebHook::EventDecorator[raw_event]
#     ..
#   end
#
class Mandrill::WebHook::EventDecorator < Hash

  # Returns the event type
  def event_type
    self['event']
  end

  # Returns the subject
  def subject
    self['subject'] || msg['subject']
  end

  # Returns the msg Hash (as used for inbound messages )
  def msg
    self['msg']||{}
  end

  # Returns the message_id (as used for inbound messages )
  def message_id
    headers['Message-Id']
  end

  # Returns the headers Hash (as used for inbound messages )
  def headers
    msg['headers']||{}
  end

  # Returns the email (String) of the sender
  def sender_email
    msg['from_email']
  end

  # Returns an array of all unique recipient emails (to/cc)
  #   [ email, email, .. ]
  def recipients
    (Array(msg['to']) | Array(msg['cc'])).compact
  end

  # Returns an array of all unique recipients (to/cc)
  #   [ [email,name], [email,name], .. ]
  def recipient_emails
    recipients.map(&:first)
  end

  # Returns the +format+ (:text,:html,:raw) message body
  def message_body(format=:text)
    case format
    when :text
      msg['text']
    when :html
      msg['html']
    when :raw
      msg['raw_msg']
    end
  end

end
