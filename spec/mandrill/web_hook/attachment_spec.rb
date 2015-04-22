require 'spec_helper'


describe Mandrill::WebHook::Attachment do

  [
    {
      :test_name => 'simple text file',
      :given => { 'name' => 'a', 'type' => 'text/plain', 'base64' => false, 'content' => 'simple text' },
      :name => 'a',
      :type => 'text/plain',
      :base64 => false,
      :raw_content_matches => 'simple text',
      :decoded_content_matches => 'simple text'
    },
    {
      :test_name => 'simple binary file',
      :given => { 'name' => 'b', 'type' => 'application/pdf', 'base64' => true, 'content' => 'JVBERi0xLjMKJcTl8uXr....' },
      :name => 'b',
      :type => 'application/pdf',
      :base64 => true,
      :raw_content_matches => /^JVBERi0xLjM/,
      :decoded_content_matches => /^%PDF-1.3/
    }
  ].each do |expectations|
    context "when given #{expectations[:test_name]}" do
      subject(:attachment) { Mandrill::WebHook::Attachment[expectations[:given]] }
      it "exposes the file correctly" do
        expect(attachment.name).to eql(expectations[:name])
        expect(attachment.type).to eql(expectations[:type])
        expect(attachment.base64).to eql(expectations[:base64])
        expect(attachment.content).to match(expectations[:raw_content_matches])
        expect(attachment.decoded_content).to match(expectations[:decoded_content_matches])
      end
    end
  end

end