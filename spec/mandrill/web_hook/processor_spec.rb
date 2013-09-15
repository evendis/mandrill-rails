require 'spec_helper'

describe Mandrill::WebHook::Processor do

  let(:params) { {} }
  let(:processor) { Mandrill::WebHook::Processor.new(params) }

  describe "#run!" do
    context "with inbound events" do
      before do
        Mandrill::WebHook::Processor.stub(:handle_inbound)
      end
      let(:event1) { { "event" => "inbound" } }
      let(:event2) { { "event" => "inbound" } }
      let(:params) { { "mandrill_events" => [event1,event2].to_json } }
      it "should pass event payload to the handler" do
        processor.should_receive(:handle_inbound).twice
        processor.run!
      end
    end
    context "with callback host" do
      let(:callback_host) do
        host = double()
        host.stub(:handle_inbound)
        host
      end
      let(:processor) { Mandrill::WebHook::Processor.new(params,callback_host) }
      let(:event1) { { "event" => "inbound" } }
      let(:event2) { { "event" => "inbound" } }
      let(:params) { { "mandrill_events" => [event1,event2].to_json } }
      it "should pass event payload to the handler" do
        callback_host.should_receive(:handle_inbound).twice
        processor.run!
      end
    end
  end

  describe "#wrap_payload" do
    let(:raw_payload) { {} }
    subject { processor.wrap_payload(raw_payload) }
    its(:class) { should eql(Mandrill::WebHook::EventDecorator) }
  end

  describe "#generate_signature" do
    let(:example_payload) { webhook_example_event('click_with_signature') }
    let(:expected_signature) { example_payload['headers']['X-Mandrill-Signature'] }
    let(:original_url) { example_payload['original_url'] }
    let(:webhook_key) { example_payload['private_key'] }
    let(:params) { example_payload['raw_params'] }
    subject { processor.send(:generate_signature, webhook_key, original_url, params)}
    it { should eql(expected_signature) }
  end

end