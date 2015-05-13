require 'spec_helper'


describe Mandrill::WebHook::Image do

  [
    {
      :test_name => 'simple image file',
      :given => { 'name' => 'c', 'type' => 'image/png', 'content' => 'iVBORw0KGgoAAAA....' },
      :name => 'c',
      :type => 'image/png',
      :base64 => true,
      :raw_content_matches => /^iVBORw0K/,
      :decoded_content_matches => /^\x89PNG\r\n/n
    }
  ].each do |expectations|
    context "when given #{expectations[:test_name]}" do
      subject(:attachment) { Mandrill::WebHook::Image[expectations[:given]] }
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
