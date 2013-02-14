require 'spec_helper'


describe Mandrill::WebHook::Attachment do

  [
    {
      :test_name => 'simple text file',
      :given => { 'name' => 'a', 'type' => 'text/plain', 'content' => 'simple text' },
      :name => 'a',
      :type => 'text/plain',
      :raw_content_matches => 'simple text',
      :decoded_content_matches => 'simple text'
    },
    {
      :test_name => 'simple binary file',
      :given => { 'name' => 'b', 'type' => 'application/pdf', 'content' => 'JVBERi0xLjMKJcTl8uXr....' },
      :name => 'b',
      :type => 'application/pdf',
      :raw_content_matches => /^JVBERi0xLjM/,
      :decoded_content_matches => /^%PDF-1.3/
    }
  ].each do |expectations|
    describe expectations[:test_name] do
      let(:attachment) { Mandrill::WebHook::Attachment[expectations[:given]] }
      subject { attachment }
      its(:name) { should eql(expectations[:name]) }
      its(:type) { should eql(expectations[:type]) }
      its(:content) { should match(expectations[:raw_content_matches]) }
      its(:decoded_content) { should match(expectations[:decoded_content_matches]) }
    end
  end

end