require 'spec_helper'

class WebHookProcessorTestHarness
  # Mock some controller behaviour
  # TODO: we should probably start using a real controller harness for testing
  def self.skip_before_filter(*args) ; @skip_before_filter_settings = args; end
  def self.skip_before_filter_settings ; @skip_before_filter_settings; end
  def self.before_filter(*args) ; @before_filter_settings = args ; end
  def self.before_filter_settings ; @before_filter_settings; end
  def head(*args) ; end
  attr_accessor :params, :request

  include Mandrill::Rails::WebHookProcessor
end

describe Mandrill::Rails::WebHookProcessor do
  let(:processor_class) { WebHookProcessorTestHarness }
  let(:processor_instance) { processor_class.new }
  before do
    # clear class instance settings
    processor_class.authenticate_with_mandrill_keys! nil
    processor_class.on_unhandled_mandrill_events! nil
  end

  describe "##skip_before_filter settings" do
    subject { processor_class.skip_before_filter_settings }
    it "includes verify_authenticity_token" do
      expect(subject).to eql([:verify_authenticity_token])
    end
  end

  describe "##before_filter settings" do
    subject { processor_class.before_filter_settings }
    it "includes authenticate_mandrill_request" do
      expect(subject).to eql([:authenticate_mandrill_request!, {:only=>[:create]}])
    end
  end

  describe "#mandrill_webhook_keys" do
    subject { processor_class.mandrill_webhook_keys }
    context "when not set" do
      it "is empty" do
        expect(subject).to eql([])
      end
    end
    context "when set with mandrill_webhook_keys=" do
      let(:expected_value) { [1,2,3] }
      before { processor_class.mandrill_webhook_keys = expected_value }
      it { should eql(expected_value) }
    end
    context "when authenticate_with_mandrill_keys! set" do
      context "with an array" do
        it "has the correct settings" do
          processor_class.authenticate_with_mandrill_keys! [4,5,6]
          expect(subject).to eql([4,5,6])
        end
      end
      context "with a list" do
        it "has the correct settings" do
          processor_class.authenticate_with_mandrill_keys! "a", "b", "c"
          expect(subject).to eql(["a", "b", "c"])
        end
      end
      context "with a single value" do
        it "has the correct settings" do
          processor_class.authenticate_with_mandrill_keys! "key_a"
          expect(subject).to eql(["key_a"])
        end
      end
      context "with nil" do
        it "has cleared settings" do
          processor_class.authenticate_with_mandrill_keys! "key_a"
          processor_class.authenticate_with_mandrill_keys! nil
          expect(subject).to eql([])
        end
      end
    end
  end

  subject { processor_instance }

  describe "#show" do
    it "should return head(:ok)" do
      expect(processor_instance).to receive(:head).with(:ok)
      processor_instance.show
    end
  end

  describe "#create" do
    let(:params) { {} }
    before do
      processor_instance.params = params
    end
    it "returns head(:ok) on success" do
      expect(processor_instance).to receive(:head).with(:ok)
      expect_any_instance_of(Mandrill::WebHook::Processor).to receive(:run!)
      expect_any_instance_of(Mandrill::WebHook::Processor).to receive(:on_unhandled_mandrill_events=).with(:log)
      processor_instance.create
    end

    context "when unhandled events set to raise exceptions" do
      it "delegates the setting to the processor" do
        processor_instance.class.unhandled_events_raise_exceptions!
        expect(processor_instance).to receive(:head).with(:ok)
        expect_any_instance_of(Mandrill::WebHook::Processor).to receive(:run!)
        expect_any_instance_of(Mandrill::WebHook::Processor).to receive(:on_unhandled_mandrill_events=).with(:raise_exception)
        processor_instance.create
      end
    end

    context "when unhandled events set to be ignored" do
      it "delegates the setting to the processor" do
        processor_instance.class.ignore_unhandled_events!
        expect(processor_instance).to receive(:head).with(:ok)
        expect_any_instance_of(Mandrill::WebHook::Processor).to receive(:run!)
        expect_any_instance_of(Mandrill::WebHook::Processor).to receive(:on_unhandled_mandrill_events=).with(:ignore)
        processor_instance.create
      end
    end

  end

  describe "#authenticate_mandrill_request! (protected)" do
    let(:example_payload) { webhook_example_event('click_with_signature') }
    let(:expected_signature) { example_payload['headers']['X-Mandrill-Signature'] }
    let(:original_url) { example_payload['original_url'] }
    let(:valid_webhook_key) { example_payload['private_key'] }
    let(:raw_params) { example_payload['raw_params'] }
    let(:params) { {} }
    let(:headers) { { 'HTTP_X_MANDRILL_SIGNATURE' => expected_signature} }
    let(:request) { double() }
    before do
      allow(request).to receive(:original_url).and_return(original_url)
      allow(request).to receive(:request_parameters).and_return(raw_params)
      allow(request).to receive(:headers).and_return(headers)
      processor_instance.request = request
      processor_instance.params = params
    end
    subject { processor_instance.send(:authenticate_mandrill_request!) }

    context "when authentication not enabled" do
      it "passes" do
        expect(subject).to eql(true)
      end
    end
    context "when authentication enabled" do
      before do
        processor_class.authenticate_with_mandrill_keys! mandrill_webhook_keys
      end
      context "with valid key" do
        let(:mandrill_webhook_keys) { valid_webhook_key }
        it "passes" do
          expect(subject).to eql(true)
        end
      end
      context "with mix of valid and invalid keys" do
        let(:mandrill_webhook_keys) { ['bogative',valid_webhook_key] }
        it "passes" do
          expect(subject).to eql(true)
        end
      end
      context "with invalid key" do
        let(:mandrill_webhook_keys) { 'bogative' }
        it "calls head(:forbidden) and return false" do
          expect(processor_instance).to receive(:head).with(:forbidden, :text => "Mandrill signature did not match.")
          expect(subject).to eql(false)
        end
      end
    end
  end

end