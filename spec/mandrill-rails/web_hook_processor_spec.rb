require 'spec_helper'

class WebHookProcessorTestHarness
  def self.skip_before_filter(*args) ; end
  def head(*args) ; end
  attr_accessor :params

  include Mandrill::Rails::WebHookProcessor
end

describe Mandrill::Rails::WebHookProcessor do
  let(:processor_instance) { WebHookProcessorTestHarness.new }
  let(:params) { {} }
  before { processor_instance.params = params}

  subject { processor_instance }

  describe "#show" do
    it "should return head(:ok)" do
      processor_instance.should_receive(:head).with(:ok)
      processor_instance.show
    end
  end

  describe "#create" do
    it "should return head(:ok)" do
      Mandrill::WebHook::Processor.any_instance.should_receive(:run!)
      processor_instance.should_receive(:head).with(:ok)
      processor_instance.create
    end
  end

  describe "#generate_signature (private)" do
    let(:example_payload) { webhook_example_event('click_with_signature') }
    let(:expected_signature) { example_payload['headers']['X-Mandrill-Signature'] }
    let(:original_url) { example_payload['original_url'] }
    let(:webhook_key) { example_payload['private_key'] }
    let(:params) { example_payload['raw_params'] }
    subject { processor_instance.send(:generate_signature, webhook_key, original_url, params)}
    it { should eql(expected_signature) }
  end

end