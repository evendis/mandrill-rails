require 'spec_helper'

class WebHookProcessorTestHarness
  def self.skip_before_filter(*args) ; end
  def head(*args) ; end
  attr_accessor :params, :request

  include Mandrill::Rails::WebHookProcessor
end

describe Mandrill::Rails::WebHookProcessor do
  let(:processor_instance) { WebHookProcessorTestHarness.new }
  let(:params) { {} }
  before do
    processor_instance.params = params
    processor_instance.class.mandrill_webhook_keys nil
  end

  subject { processor_instance }

  describe "#show" do
    it "should return head(:ok)" do
      processor_instance.should_receive(:head).with(:ok)
      processor_instance.show
    end
  end

  describe "#create" do
    context "when authentication not enabled" do
      it "should return head(:ok)" do
        processor_instance.should_receive(:head).with(:ok)
        Mandrill::WebHook::Processor.any_instance.should_receive(:run!)
        processor_instance.create
      end
    end
    context "when authentication enabled" do
      let(:example_payload) { webhook_example_event('click_with_signature') }
      let(:expected_signature) { example_payload['headers']['X-Mandrill-Signature'] }
      let(:original_url) { example_payload['original_url'] }
      let(:valid_webhook_key) { example_payload['private_key'] }
      let(:raw_params) { example_payload['raw_params'] }
      let(:headers) { { 'HTTP_X_MANDRILL_SIGNATURE' => expected_signature} }
      let(:request) { double() }
      before do
        request.stub(:original_url).and_return(original_url)
        request.stub(:params).and_return(raw_params)
        request.stub(:headers).and_return(headers)
        processor_instance.request = request
        processor_instance.class.mandrill_webhook_keys mandrill_webhook_keys
      end
      context "with valid key" do
        let(:mandrill_webhook_keys) { valid_webhook_key }
        it "should return head(:ok)" do
          processor_instance.should_receive(:head).with(:ok)
          Mandrill::WebHook::Processor.any_instance.should_receive(:run!)
          processor_instance.create
        end
      end
      context "with mix of valid and invalid keys" do
        let(:mandrill_webhook_keys) { ['bogative',valid_webhook_key] }
        it "should return head(:ok)" do
          processor_instance.should_receive(:head).with(:ok)
          Mandrill::WebHook::Processor.any_instance.should_receive(:run!)
          processor_instance.create
        end
      end
      context "with invalid key" do
        let(:mandrill_webhook_keys) { 'bogative' }
        it "should return head(:forbidden)" do
          processor_instance.should_receive(:head).with(:forbidden, :text => "Mandrill signature did not match.")
          Mandrill::WebHook::Processor.any_instance.should_receive(:run!).never
          processor_instance.create
        end
      end
    end
  end

  describe "##mandrill_webhook_keys" do
    subject { processor_instance.class.mandrill_webhook_keys }
    it { should eql([]) }
    context "when set with a single value" do
      let(:key_a) { "key_a" }
      before { processor_instance.class.mandrill_webhook_keys key_a }
      it { should eql([key_a]) }
      context "then called with nil" do
        before { processor_instance.class.mandrill_webhook_keys nil }
        it { should eql([]) }
      end
    end
    context "when set with a list of values" do
      let(:key_a) { "key_a" }
      let(:key_b) { "key_b" }
      before { processor_instance.class.mandrill_webhook_keys key_a, key_b }
      it { should eql([key_a,key_b]) }
    end
    context "when set with an explicit array of values" do
      let(:key_a) { "key_a" }
      let(:key_b) { "key_b" }
      before { processor_instance.class.mandrill_webhook_keys [key_a, key_b] }
      it { should eql([key_a,key_b]) }
    end
  end

end