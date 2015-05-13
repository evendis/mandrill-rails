class Mandrill::WebHook::Image < Mandrill::WebHook::Attachment

  # Images are always sent base64-encoded, but are missing the base64 boolean
  def base64
    true
  end

end
