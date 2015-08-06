require 'spec_helper'


describe Mandrill::WebHook::EventDecorator do

  # Test decorator behaviour given the range of example Mandrill event types:
  #
  # * inbound - inbound mail receipt
  # * send - message has been sent
  # * click - recipient clicked a link in a message; will only occur when click tracking is enabled
  # * open - recipient opened a message; will only occur when open tracking is enabled
  #
  # TODO: need to collect some real examples for the following event types:
  # * hard_bounce - message has hard bounced
  # * reject - message was rejected
  # * soft_bounce - message has soft bounced
  # * spam - recipient marked a message as spam
  # * unsub - recipient unsubscribed
  #
  {
    'inbound' => {
      :event_type => 'inbound',
      :sync_type => nil,
      :reject => {},
      :subject => '[inbound] Sample Subject',
      :message_id => '<CAGBx7GhULS7d6ZsdLREHnKQ68V6w2fbGmD85dPn63s6RtpsZeQ@mail.gmail.com>',
      :message_version => nil,
      :in_reply_to => nil,
      :references => [],
      :headers => {
        "Content-Type" => "multipart/alternative; boundary=e0cb4efe2faee9b97304c6d0647b",
        "Date" => "Thu, 9 Aug 2012 15:44:15 +0800",
        "Dkim-Signature" => "v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20120113; h=mime-version:date:message-id:subject:from:to:content-type; bh=9/e4o7vsyI5eIM2MUze13ZWWdxyhC7cxjHwrHXPSEJQ=; b=HOb83u8i6ai3HuT61C+NfQcUHqATH+/ivAjZ2pD/MXcCFboOyN9LGeMHm+RhwnL+Ap mC0R9+eqlWaoxqd6ugrvtNOQ1Kvb9LunPnnMwY06KZKpoXCVwFrzT3e2f8JgLwyAxpUv G0srziHwpuCh/y42dJ83tKhctHc6w6GKC79H1WBAcexnjvk0LgrkOnNJ/iBCOznjs35o V4jfjlJBeZLvxcnEJ5Xxade2kWbLZ9TWiuVfTS6xUyVb/gfn5x9D1KjCUb1Gwq9wYJ4m UxH6oC5f3mkM+NZ6oDBmJFDdVxg23rRaMrF4YBpVGj+6+pjF36N8CrmtaDOJNVqCS5FN koSw==",
        "From" => "From Name <from@example.com>",
        "Message-Id" => "<CAGBx7GhULS7d6ZsdLREHnKQ68V6w2fbGmD85dPn63s6RtpsZeQ@mail.gmail.com>",
        "Mime-Version" => "1.0",
        "Received" => [ "from mail-lpp01m010-f51.google.com (mail-lpp01m010-f51.google.com [209.85.215.51]) by app01.transact (Postfix) with ESMTPS id F01841E0010A for <to@example.com>; Thu, 9 Aug 2012 03:44:16 -0400 (EDT)", "by lahe6 with SMTP id e6so79326lah.24 for <to@example.com>; Thu, 09 Aug 2012 00:44:15 -0700 (PDT)", "by 10.112.43.67 with SMTP id u3mr382471lbl.16.1344498255378; Thu, 09 Aug 2012 00:44:15 -0700 (PDT)", "by 10.114.69.44 with HTTP; Thu, 9 Aug 2012 00:44:15 -0700 (PDT)" ],
        "Subject" => "[inbound] Sample Subject",
        "To" => "to@example.com"
      },
      :sender_email => 'from@example.com',
      :user_email => 'from@example.com',
      :recipients => [["to@example.com", nil]],
      :recipient_emails => ["to@example.com"],
      :message_body => "multi-line content\n\n*multi-line content\n*\n*with some formatting*\n\nmulti-line content\n\n",
      :click => nil,
      :all_clicks => [],
      :all_clicked_links => []
    },
    'inbound_reply' => {
      :event_type => 'inbound',
      :sync_type => nil,
      :reject => {},
      :subject => '[inbound] Sample Subject 2',
      :message_id => '<CAGBx7GhsVk7Q-aO-FQ-m+Oix7GQyEVHyL60qv0__G8EpH8pA4w@mail.gmail.com>',
      :message_version => nil,
      :in_reply_to => "<CAGBx7GhULS7d6ZsdLREHnKQ68V6w2fbGmD85dPn63s6RtpsZeQ@mail.gmail.com>",
      :references => ["<CAGBx7GhULS7d6ZsdLREHnKQ68V6w2fbGmD85dPn63s6RtpsZeQ@mail.gmail.com>", "<9999999999999@mail.gmail.com>"],
      :headers => {
        "Cc" => "cc@example.com",
        "Content-Type" => "multipart/alternative; boundary=f46d040838d398472904c6d067c6",
        "Date" => "Thu, 9 Aug 2012 15:45:00 +0800",
        "Dkim-Signature" => "v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20120113; h=mime-version:date:message-id:subject:from:to:cc:content-type; bh=hZurAGSA3OJIqtMOebHDdMvqss5GY1RDg7kV68+nvN8=; b=g9eCMb+rDV2RIp8stEri4PjLRHqxPECKEJcP/uMEcWZcWqDOlV9QBlOUAptAHMDv1F tIbDJBx+59t5q1hMr2sfn8CUl4T1oaXZq9Gu3SvGxlLX4HFGEQZBAUq+kfW+M8mNWHs9 SkNxsO1gmgjuht1hGOP4rxkEj/tRM+NXBiqB8UOzaF3BBI/NtjjKjbLu+VshGadTDoeQ ayQ6d6r5Sl+BE0PNLF65H8WJF0VyzTsTOSKAynRGGoLCaO+gzgxSwQe5+w9spw0SMSRY +it9DSZm1en+BsfMNlcbkUqN5a9ova+q4whSjdq4NoTrCaZS/6ZTVbBjc/HK2IQYQI4/ CTDw==",
        "From" => "From Name <from@example.com>",
        "Message-Id" => "<CAGBx7GhsVk7Q-aO-FQ-m+Oix7GQyEVHyL60qv0__G8EpH8pA4w@mail.gmail.com>",
        "In-Reply-To" => "<CAGBx7GhULS7d6ZsdLREHnKQ68V6w2fbGmD85dPn63s6RtpsZeQ@mail.gmail.com>",
        "References" => "<CAGBx7GhULS7d6ZsdLREHnKQ68V6w2fbGmD85dPn63s6RtpsZeQ@mail.gmail.com> <9999999999999@mail.gmail.com>",
        "Mime-Version" => "1.0",
        "Received" => [ "from mail-lb0-f179.google.com (mail-lb0-f179.google.com [209.85.217.179]) by app01.transact (Postfix) with ESMTPS id E94801E000B8 for <to@example.com>; Thu, 9 Aug 2012 03:45:01 -0400 (EDT)",
        "by lbao2 with SMTP id o2so118681lba.24 for <to@example.com>; Thu, 09 Aug 2012 00:45:00 -0700 (PDT)",
        "by 10.152.112.233 with SMTP id it9mr20848692lab.40.1344498300372; Thu, 09 Aug 2012 00:45:00 -0700 (PDT)",
        "by 10.114.69.44 with HTTP; Thu, 9 Aug 2012 00:45:00 -0700 (PDT)" ],
        "Subject" => "[inbound] Sample Subject 2",
        "To" => "to@example.com, Other To <other.to@example.com>"
      },
      :sender_email => 'from@example.com',
      :user_email => 'from@example.com',
      :recipients => [["to@example.com,", nil], ["other.to@example.com", " Other To "], ["cc@example.com", nil]],
      :recipient_emails => ["to@example.com,", "other.to@example.com", "cc@example.com"],
      :message_body => "asfasdf\nasdf\nasdf\nasdf\nasdf\n\n",
      :click => nil,
      :all_clicks => [],
      :all_clicked_links => []
    },
    'click' => {
      :event_type => 'click',
      :sync_type => nil,
      :reject => {},
      :subject => '[click] Sample Subject',
      :message_id => '8606637.6692f6cac28e45a9b371e182d5ca0a35',
      :message_version => 5,
      :in_reply_to => nil,
      :references => [],
      :headers => {},
      :sender_email => 'from@example.com',
      :user_email => 'to@example.com',
      :recipients => [],
      :recipient_emails => [],
      :message_body => nil,
      :click => {"ts"=>1350377135, "url"=>"http://feedproxy.google.com/~r/readwriteweb/~3/op1uGAwjnFo/fix-your-iphones-maps-reminders-with-localscope-3.php"},
      :all_clicks => [
        {"ts"=>1350347773, "url"=>"http://feedproxy.google.com/~r/readwriteweb/~3/rqUHtsdBCzc/saturday-night-live-sketch-skewers-iphone-5-and-the-tech-press-video.php"},
        {"ts"=>1350377171, "url"=>"http://feedproxy.google.com/~r/readwriteweb/~3/MMUCngEPdSU/now-you-can-search-your-email-docs-spreadsheets-from-the-main-google-box.php"},
        {"ts"=>1350377231, "url"=>"http://feedproxy.google.com/~r/readwriteweb/~3/KemlM1hZvdI/how-evil-is-your-smartphone.php"},
        {"ts"=>1350377135, "url"=>"http://feedproxy.google.com/~r/readwriteweb/~3/op1uGAwjnFo/fix-your-iphones-maps-reminders-with-localscope-3.php"}
      ],
      :all_clicked_links => [
        "http://feedproxy.google.com/~r/readwriteweb/~3/rqUHtsdBCzc/saturday-night-live-sketch-skewers-iphone-5-and-the-tech-press-video.php",
        "http://feedproxy.google.com/~r/readwriteweb/~3/MMUCngEPdSU/now-you-can-search-your-email-docs-spreadsheets-from-the-main-google-box.php",
        "http://feedproxy.google.com/~r/readwriteweb/~3/KemlM1hZvdI/how-evil-is-your-smartphone.php",
        "http://feedproxy.google.com/~r/readwriteweb/~3/op1uGAwjnFo/fix-your-iphones-maps-reminders-with-localscope-3.php"
      ]
    },
    'send' => {
      :event_type => 'send',
      :sync_type => nil,
      :reject => {},
      :subject => '[send] Sample Subject',
      :message_id => '9a32184309ad4d5e9bfd20368d9d7981',
      :message_version => nil,
      :in_reply_to => nil,
      :references => [],
      :headers => {},
      :sender_email => 'from@example.com',
      :user_email => 'to@example.com',
      :recipients => [],
      :recipient_emails => [],
      :message_body => nil,
      :click => nil,
      :all_clicks => [],
      :all_clicked_links => []
    },
    'open' => {
      :event_type => 'open',
      :sync_type => nil,
      :reject => {},
      :subject => '[open] Sample Subject',
      :message_id => '12847763.9a32184309ad4d5e9bfd20368d9d7981',
      :message_version => 3,
      :in_reply_to => nil,
      :references => [],
      :headers => {},
      :sender_email => 'from@example.com',
      :user_email => 'to@example.com',
      :recipients => [],
      :recipient_emails => [],
      :message_body => nil,
      :click => nil,
      :all_clicks => [{"ts"=>1350693098, "url"=>"http://feedproxy.google.com/~r/AccidentalTechnologist/~3/Jc7hYTVjcmM/"}],
      :all_clicked_links => ["http://feedproxy.google.com/~r/AccidentalTechnologist/~3/Jc7hYTVjcmM/"]
    },
    'sync_blacklist' => {
      :event_type => 'sync',
      :sync_type => 'blacklist',
      :reject => {
        "reason"=>"hard-bounce",
        "detail"=>"Example detail",
        "last_event_at"=>"2014-02-01 12:43:56",
        "email"=>"example.webhook@mandrillapp.com",
        "created_at"=>"2014-01-15 11:32:19",
        "expires_at"=>"2020-04-02 12:09:18",
        "expired"=>false,
        "subaccount"=>"example_subaccount",
        "sender"=>"example.sender@mandrillapp.com"
      },
      :subject => nil,
      :message_id => nil,
      :message_version => nil,
      :in_reply_to => nil,
      :references => [],
      :headers => {},
      :sender_email => "example.sender@mandrillapp.com",
      :user_email => "example.webhook@mandrillapp.com",
      :recipients => [],
      :recipient_emails => [],
      :message_body => nil,
      :click => nil,
      :all_clicks => [],
      :all_clicked_links => []
    },
    'sync_whitelist' => {
      :event_type => 'sync',
      :sync_type => 'whitelist',
      :entry => {
        "detail"=>"example details",
        "email"=>"example.webhook@mandrillapp.com",
        "created_at"=>"2014-01-15 12:03:19"
      },
      :subject => nil,
      :message_id => nil,
      :message_version => nil,
      :in_reply_to => nil,
      :references => [],
      :headers => {},
      :sender_email => nil,
      :user_email => "example.webhook@mandrillapp.com",
      :recipients => [],
      :recipient_emails => [],
      :message_body => nil,
      :click => nil,
      :all_clicks => [],
      :all_clicked_links => []
    }
  }.each do |event_type,expectations|
    context "with #{event_type} event_type" do
      let(:raw_event) { webhook_example_event(event_type) }
      subject(:event_payload) { Mandrill::WebHook::EventDecorator[raw_event] }
      expectations.each do |attribute,expected_value|
        it "has the correct #{attribute} value" do
          expect(subject.send(attribute)).to eql(expected_value)
        end
      end
    end
  end


  describe "#message_body" do
    let(:raw_event) { webhook_example_event('inbound') }
    subject(:event_payload) { Mandrill::WebHook::EventDecorator[raw_event] }

    it "formats the message_body correctly" do
      expected_text = "multi-line content\n\n*multi-line content\n*\n*with some formatting*\n\nmulti-line content\n\n"
      expect(event_payload.message_body(:text)).to eql(expected_text)

      expected_html = "multi-line content<br><br><b>multi-line content<br></b>\n<br><i>with some formatting</i><br><br>\nmulti-line content<br>\n<br>\n<br>\n\n"
      expect(event_payload.message_body(:html)).to eql(expected_html)

      expected_raw = "Received: from mail-lpp01m010-f51.google.com (mail-lpp01m010-f51.google.com [209.85.215.51])\n\tby app01.transact (Postfix) with ESMTPS id F01841E0010A\n\tfor <to@example.com>; Thu, 9 Aug 2012 03:44:16 -0400 (EDT)\nReceived: by lahe6 with SMTP id e6so79326lah.24\n for <to@example.com>; Thu, 09 Aug 2012 00:44:15 -0700 (PDT)\nDKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;\n d=gmail.com; s=20120113;\n h=mime-version:date:message-id:subject:from:to:content-type;\n bh=9/e4o7vsyI5eIM2MUze13ZWWdxyhC7cxjHwrHXPSEJQ=;\n b=HOb83u8i6ai3HuT61C+NfQcUHqATH+/ivAjZ2pD/MXcCFboOyN9LGeMHm+RhwnL+Ap\n mC0R9+eqlWaoxqd6ugrvtNOQ1Kvb9LunPnnMwY06KZKpoXCVwFrzT3e2f8JgLwyAxpUv\n G0srziHwpuCh/y42dJ83tKhctHc6w6GKC79H1WBAcexnjvk0LgrkOnNJ/iBCOznjs35o\n V4jfjlJBeZLvxcnEJ5Xxade2kWbLZ9TWiuVfTS6xUyVb/gfn5x9D1KjCUb1Gwq9wYJ4m\n UxH6oC5f3mkM+NZ6oDBmJFDdVxg23rRaMrF4YBpVGj+6+pjF36N8CrmtaDOJNVqCS5FN\n koSw==\nMIME-Version: 1.0\nReceived: by 10.112.43.67 with SMTP id u3mr382471lbl.16.1344498255378; Thu, 09\n Aug 2012 00:44:15 -0700 (PDT)\nReceived: by 10.114.69.44 with HTTP; Thu, 9 Aug 2012 00:44:15 -0700 (PDT)\nDate: Thu, 9 Aug 2012 15:44:15 +0800\nMessage-ID: <CAGBx7GhULS7d6ZsdLREHnKQ68V6w2fbGmD85dPn63s6RtpsZeQ@mail.gmail.com>\nSubject: [inbound] Sample Subject\nFrom: From Name <from@example.com>\nTo: to@example.com\nContent-Type: multipart/alternative; boundary=e0cb4efe2faee9b97304c6d0647b\n\n--e0cb4efe2faee9b97304c6d0647b\nContent-Type: text/plain; charset=UTF-8\n\nmulti-line content\n\n*multi-line content\n*\n*with some formatting*\n\nmulti-line content\n\n--e0cb4efe2faee9b97304c6d0647b\nContent-Type: text/html; charset=UTF-8\n\nmulti-line content<br><br><b>multi-line content<br></b>\n<br><i>with some formatting</i><br><br>\nmulti-line content<br>\n<br>\n<br>\n\n--e0cb4efe2faee9b97304c6d0647b--\n"
      expect(event_payload.message_body(:raw)).to eql(expected_raw)
    end

    context "when msg is missing" do
      let(:raw_event) { webhook_example_event('inbound_without_msg') }

      it "has null message attributes" do
        expect(subject.message_body).to be_nil
        expect(subject.message_id).to be_nil
        expect(subject.sender_email).to be_nil
      end
    end

    context "with html-only payload; see github issue \#8" do
      let(:raw_event) { webhook_example_event('inbound_html_only') }

      it "has all message attributes except text body" do
        expect(subject.message_body).to be_present
        expect(subject.message_body(:html)).to be_present
        expect(subject.message_body(:text)).to be_nil
        expect(subject.message_id).to eql('<OFA804C4DE.C8619FB4-ON80257C30.004A7A89-80257C30.004A7A94@xxxxx.co.uk>')
        expect(subject.sender_email).to eql('Leeroy.xxxx@xxxx.co.uk')
      end
    end

    context "with text-only payload" do
      let(:raw_event) { webhook_example_event('inbound_text_only') }

      it "has all message attributes except html body" do
        expect(subject.message_body).to be_present
        expect(subject.message_body(:html)).to be_nil
        expect(subject.message_body(:text)).to be_present
        expect(subject.message_id).to eql('<CAGBx7Gg-CUco7NNsA79Ss1QMFTaXvyWnqkt26=RJr-ktSoRB0A@mail.gmail.com>')
        expect(subject.sender_email).to eql('from@example.com')
      end
    end
  end

  describe "#attachments" do
    let(:event_payload)   { Mandrill::WebHook::EventDecorator[raw_event] }
    let(:attachment)      { attachments.first }
    subject(:attachments) { event_payload.attachments }

    context "when single text attachment" do
      let(:raw_event)  { webhook_example_event('inbound_with_txt_attachment') }

      it "is presented in attachments accessor correctly" do
        expect(attachments.count).to eql(1)
        expect(attachment.name).to eql('sample.txt')
        expect(attachment.type).to eql('text/plain')
        expect(attachment.base64).to be(false)
        expect(attachment.content).to eql("This is \na sample\ntext file\n")
        expect(attachment.decoded_content).to eql("This is \na sample\ntext file\n")
        expect(attachment.decoded_content).to eql(payload_example('sample.txt'))
      end
    end

    context "when single pdf attachment" do
      let(:raw_event) { webhook_example_event('inbound_with_pdf_attachment') }
      it "is presented in attachments accessor correctly" do
        expect(attachments.count).to eql(1)
        expect(attachment.name).to eql('sample.pdf')
        expect(attachment.type).to eql('application/pdf')
        expect(attachment.base64).to be(true)
        expect(attachment.content).to match(/^JVBERi0xL/)
        expect(attachment.decoded_content).to match(/^%PDF-1.3/)
      end
      it "decoded_content exactly matches the original" do
        original_digest = Digest::SHA1.hexdigest(payload_example('sample.pdf'))
        decoded_digest = Digest::SHA1.hexdigest(attachment.decoded_content)
        expect(original_digest).to eql(decoded_digest)
      end
    end

    context "when multiple attachments" do
      let(:raw_event) { webhook_example_event('inbound_with_multiple_attachments') }
      it "are presented in attachments accessor correctly" do
        expect(attachments.count).to eql(2)
      end
      describe "pdf attachment" do
        subject(:attachment) { attachments.select{|a| a.type =~ /pdf/ }.first }
        it "has correct attributes" do
          expect(attachment.name).to eql('sample.pdf')
          expect(attachment.type).to eql('application/pdf')
          expect(attachment.base64).to be(true)
          expect(attachment.content).to match(/^JVBERi0xL/)
          expect(attachment.decoded_content).to match(/^%PDF-1.3/)
        end
      end
      describe "txt attachment" do
        subject(:attachment) { attachments.select{|a| a.type =~ /plain/ }.first }
        it "has correct attributes" do
          expect(attachment.name).to eql('sample.txt')
          expect(attachment.type).to eql('text/plain')
          expect(attachment.base64).to be(false)
          expect(attachment.content).to eql("This is \na sample\ntext file\n")
          expect(attachment.decoded_content).to eql("This is \na sample\ntext file\n")
        end
      end
    end

  end

  describe "#images" do
    let(:event_payload) { Mandrill::WebHook::EventDecorator[raw_event] }
    let(:image)         { images.first }
    subject(:images)    { event_payload.images }

    context "when single image" do
      let(:raw_event) { webhook_example_event('inbound_with_image') }
      it "is presented in images accessor correctly" do
        expect(images.count).to eql(1)
        expect(image.name).to eql('sample.png')
        expect(image.type).to eql('image/png')
        expect(image.content).to match(/^iVBORw0K/)
        expect(image.decoded_content).to match(/^\x89PNG\r\n/n)
      end
      it "has decoded_content exactly matching the original" do
        original_digest = Digest::SHA1.hexdigest(payload_example('sample.png'))
        decoded_digest = Digest::SHA1.hexdigest(image.decoded_content)
        expect(original_digest).to eql(decoded_digest)
      end
    end

    context "when multiple images" do
      let(:raw_event) { webhook_example_event('inbound_with_multiple_images') }
      it "are presented in images accessor correctly" do
        expect(images.count).to eql(2)
      end
      describe "jpg image" do
        subject(:image) { images.select{|a| a.type =~ /jpeg/ }.first }
        it "has correct attributes" do
          expect(image.name).to eql('sample.jpg')
          expect(image.type).to eql('image/jpeg')
          expect(image.content).to match(/^\/9j\/4AAQSkZJRg/)
          expect(image.decoded_content).to match(/^\xFF\xD8\xFF\xE0\x00\x10JFIF/n)
        end
      end
      describe "png image" do
        subject(:image) { images.select{|a| a.type =~ /png/ }.first }
        it "has correct attributes" do
          expect(image.name).to eql('sample.png')
          expect(image.type).to eql('image/png')
          expect(image.content).to match(/^iVBORw0K/)
          expect(image.decoded_content).to match(/^\x89PNG\r\n/n)
        end
      end
    end

  end


end

