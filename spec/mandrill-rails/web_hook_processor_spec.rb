require 'spec_helper'

class WebHookProcessorTestHarness
  # Mock some controller behaviour
  # TODO: we should probably really start using a real controller harness for testing
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
    processor_class.authenticate_with_mandrill_keys! nil
  end

  describe "##skip_before_filter settings" do
    subject { processor_class.skip_before_filter_settings }
    it { should eql([:verify_authenticity_token]) }
  end

  describe "##before_filter settings" do
    subject { processor_class.before_filter_settings }
    it { should eql([:authenticate_mandrill_request!, {:only=>[:create]}]) }
  end

  describe "##authenticate_with_mandrill_keys!" do
    subject { processor_class.mandrill_webhook_keys }
    it { should eql([]) }
    context "when set with a single value" do
      let(:key_a) { "key_a" }
      before { processor_class.authenticate_with_mandrill_keys! key_a }
      it { should eql([key_a]) }
      context "then called with nil" do
        before { processor_class.authenticate_with_mandrill_keys! nil }
        it { should eql([]) }
      end
    end
    context "when set with a list of values" do
      let(:key_a) { "key_a" }
      let(:key_b) { "key_b" }
      before { processor_class.authenticate_with_mandrill_keys! key_a, key_b }
      it { should eql([key_a,key_b]) }
    end
    context "when set with an explicit array of values" do
      let(:key_a) { "key_a" }
      let(:key_b) { "key_b" }
      before { processor_class.authenticate_with_mandrill_keys! [key_a, key_b] }
      it { should eql([key_a,key_b]) }
    end
  end

  describe "#mandrill_webhook_keys" do
    subject { processor_class.mandrill_webhook_keys }
    it { should eql([]) }
    context "when set with mandrill_webhook_keys=" do
      let(:expected_value) { [1,2,3] }
      before { processor_class.mandrill_webhook_keys = expected_value }
      it { should eql(expected_value) }
    end
    context "when set with authenticate_with_mandrill_keys!" do
      let(:expected_value) { [4,5,6] }
      before { processor_class.authenticate_with_mandrill_keys! expected_value }
      it { should eql(expected_value) }
    end
  end


  subject { processor_instance }

  describe "#show" do
    it "should return head(:ok)" do
      processor_instance.should_receive(:head).with(:ok)
      processor_instance.show
    end
  end

  describe "#create" do
    let(:params) { {} }
    before do
      processor_instance.params = params
    end
    it "should return head(:ok)" do
      processor_instance.should_receive(:head).with(:ok)
      Mandrill::WebHook::Processor.any_instance.should_receive(:run!)
      processor_instance.create
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
      request.stub(:original_url).and_return(original_url)
      request.stub(:params).and_return(raw_params)
      request.stub(:headers).and_return(headers)
      processor_instance.request = request
      processor_instance.params = params
    end
    subject { processor_instance.send(:authenticate_mandrill_request!) }

    context "when authentication not enabled" do
      it { should be_true }
    end
    context "when authentication enabled" do
      before do
        processor_class.authenticate_with_mandrill_keys! mandrill_webhook_keys
      end
      context "with valid key" do
        let(:mandrill_webhook_keys) { valid_webhook_key }
        it { should be_true }
      end
      context "with mix of valid and invalid keys" do
        let(:mandrill_webhook_keys) { ['bogative',valid_webhook_key] }
        it { should be_true }
      end
      context "with invalid key" do
        let(:mandrill_webhook_keys) { 'bogative' }
        it "should call head(:forbidden) and return false" do
          processor_instance.should_receive(:head).with(:forbidden, :text => "Mandrill signature did not match.")
          subject.should be_false
        end
      end
    end
  end

end