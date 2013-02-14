require 'base64'

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

  # Returns the event type.
  # Applicable events: all
  def event_type
    self['event']
  end

  # Returns the message subject.
  # Applicable events: all
  def subject
    self['subject'] || msg['subject']
  end

  # Returns the msg Hash.
  # Applicable events: all
  def msg
    self['msg']||{}
  end

  # Returns the message_id.
  # Inbound events: references 'Message-Id' header.
  # Send/Open/Click events: references '_id' message attribute.
  def message_id
    headers['Message-Id'] || msg['_id']
  end

  # Returns the Mandrill message version.
  # Send/Click events: references '_version' message attribute.
  # Inbound/Open events: n/a.
  def message_version
    msg['_version']
  end

  # Returns the reply-to ID.
  # Applicable events: inbound
  def in_reply_to
    headers['In-Reply-To']
  end

  # Returns an array of reference IDs.
  # Applicable events: inbound
  def references
    (headers['References']||'').scan(/(<[^<]+?>)/).flatten
  end

  # Returns the headers Hash.
  # Applicable events: inbound
  def headers
    msg['headers']||{}
  end

  # Returns the email (String) of the sender.
  # Applicable events: inbound
  def sender_email
    msg['from_email']
  end

  # Returns the subject user email address.
  # Inbound messages: references 'email' message attribute (represents the sender).
  # Send/Open/Click messages: references 'email' message attribute (represents the recipient).
  def user_email
    msg['email']
  end

  # Returns an array of all unique recipients (to/cc)
  #   [ [email,name], [email,name], .. ]
  # Applicable events: inbound
  def recipients
    (Array(msg['to']) | Array(msg['cc'])).compact
  end

  # Returns an array of all unique recipient emails (to/cc)
  #   [ email, email, .. ]
  # Applicable events: inbound
  def recipient_emails
    recipients.map(&:first)
  end

  # Returns an array of all attachments
  #   [ {..}, {..}, .. ]
  # Each attachment is describe as a hash with three elements:
  #   'name' => the filename
  #   'type' => the content mime type
  #   'content' => the raw content, which will be base64-encoded if not plain text
  # Applicable events: inbound
  def attachments
    (msg['attachments']||{}).map(&:last)
  end

  # Returns the decoded content for attachment +index+ (0-based array index)
  def decoded_attachment_content(index=0)
    if attachment = (attachments[index]||{})
      case attachment['type']
      when 'text/plain'
        attachment['content']
      else # assume it is base64-encoded
        Base64.decode64(attachment['content'])
      end
    end
  end

  # Returns the +format+ (:text,:html,:raw) message body.
  # Applicable events: inbound
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

  # Returns the primary click payload or nil if n/a.
  # Applicable events: click, open
  def click
    { 'ts' => self['ts'], 'url' => self['url'] } if self['ts'] && self['url']
  end

  # Returns an array of all the clicks.
  # Applicable events: click, open
  def all_clicks
    clicks = msg['clicks'] || []
    clicks << click if click and clicks.empty?
    clicks
  end

  # Returns an array of all the urls marked as clicked in this message.
  # Applicable events: click, open
  def all_clicked_links
    all_clicks.collect{|c| c['url'] }.uniq
  end
end
