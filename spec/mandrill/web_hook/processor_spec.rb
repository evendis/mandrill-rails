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
  end

  describe "#wrap_payload" do
    let(:raw_payload) { {} }
    subject { processor.wrap_payload(raw_payload) }
    its(:class) { should eql(Mandrill::WebHook::EventDecorator) }
  end

end