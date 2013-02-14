require 'base64'

# Wraps an individual (file) attachment as part of a Mandrill event payload.
#
# Each attachment is described in the raw Mandrill payload as a hash with three elements:
#   'name' => the filename
#   'type' => the content mime type
#   'content' => the raw content, which will be base64-encoded if not plain text
#
class Mandrill::WebHook::Attachment < Hash

  # Returns the attachment name
  def name
    self['name']
  end

  # Returns the attachment mime type
  def type
    self['type']
  end

  # Returns the raw attachment content, which may be base64 encoded if not plain text
  def content
    self['content']
  end

  # Returns the decoded content for the attachment
  def decoded_content
    if type =~ /^text/
      content
    else # assume it is base64-encoded
      Base64.decode64(content)
    end
  rescue # any decoding error, just return the content
    content
  end

end