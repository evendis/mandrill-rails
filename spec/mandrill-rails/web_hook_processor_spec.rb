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

end