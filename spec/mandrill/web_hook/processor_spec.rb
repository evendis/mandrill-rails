require 'spec_helper'

describe Mandrill::WebHook::Processor do

  let(:params) { {} }
  let(:processor_class) { Mandrill::WebHook::Processor }
  let(:processor) { processor_class.new(params) }

  describe "#run!" do

    context "when handler methods are present" do
      let(:event1) { { "event" => "inbound" } }
      let(:event2) { { "event" => "click" } }
      let(:event3) { { "type" => "blacklist" } }
      let(:params) { { "mandrill_events" => [event1, event2, event3].to_json } }

      before do
        allow(processor_class).to receive(:handle_inbound)
        allow(processor_class).to receive(:handle_click)
        allow(processor_class).to receive(:handle_sync)
      end

      it "passes all event payloads to the handler" do
        expect(processor).to receive(:handle_inbound)
        expect(processor).to receive(:handle_click)
        expect(processor).to receive(:handle_sync)
        processor.run!
      end
    end
    context "but no valid handler methods are present" do
      let(:params) { nil }
      it "keeps calm and carries on" do
        processor.run!
      end
    end

    context "with callback host" do
      let(:callback_host) { callback_host_class.new }
      let(:processor) { processor_class.new(params,callback_host) }
      let(:event1) { { "event" => "inbound" } }
      let(:event2) { { "event" => "inbound" } }
      let(:params) { { "mandrill_events" => [event1,event2].to_json } }

      context "with handler method as public" do
        let(:callback_host_class) do
          Class.new do
            public

            def handle_inbound; end
          end
        end

        it "passes event payload to the handler" do
          expect(callback_host).to receive(:handle_inbound).twice
          processor.run!
        end
      end
      context "with handler method as protected" do
        let(:callback_host_class) do
          Class.new do
            protected

            def handle_inbound; end
          end
        end

        it "passes event payload to the handler" do
          expect(callback_host).to receive(:handle_inbound).twice
          processor.run!
        end
      end
      context "with handler method as private" do
        let(:callback_host_class) do
          Class.new do
            private

            def handle_inbound; end
          end
        end

        it "passes event payload to the handler" do
          expect(callback_host).to receive(:handle_inbound).twice
          processor.run!
        end
      end

      context "with unhandled event" do
        let(:callback_host_class) do
          Class.new do
          end
        end
        context "and default missing handler behaviour" do
          it "logs an error" do
            processor.on_unhandled_mandrill_events = :log
            logger = double()
            expect(logger).to receive(:error).twice
            expect(Rails).to receive(:logger).twice.and_return(logger)
            expect { processor.run! }.to_not raise_error
          end
        end

        context "and ignore missing handler behaviour" do
          it "keeps calm and carries on" do
            processor.on_unhandled_mandrill_events = :ignore
            expect { processor.run! }.to_not raise_error
          end
        end

        context "and raise_exception missing handler behaviour" do
          it "raises an error" do
            processor.on_unhandled_mandrill_events = :raise_exception
            expect { processor.run! }
            .to raise_error(Mandrill::Rails::Errors::MissingEventHandler)
          end
        end
      end
    end
  end

  describe "##authentic?" do
    let(:example_payload) { webhook_example_event('click_with_signature') }
    let(:expected_signature) { example_payload['headers']['X-Mandrill-Signature'] }
    let(:original_url) { example_payload['original_url'] }
    let(:webhook_key) { example_payload['private_key'] }
    let(:mandrill_webhook_keys) { [webhook_key] }
    let(:params) { example_payload['raw_params'] }
    subject { processor_class.authentic?(expected_signature, mandrill_webhook_keys, original_url, params) }
    context "when valid" do
      it "passes" do
        expect(subject).to eql(true)
      end
    end
    context "when no keys" do
      let(:mandrill_webhook_keys) { [] }
      it "passes" do
        expect(subject).to eql(true)
      end
    end
    context "when keys don't match" do
      let(:mandrill_webhook_keys) { ['bogative'] }
      it "fails" do
        expect(subject).to eql(false)
      end
    end
    context "when signature don't match" do
      let(:expected_signature) { 'bogative' }
      it "fails" do
        expect(subject).to eql(false)
      end
    end


  end

  describe "##generate_signature" do
    let(:example_payload) { webhook_example_event('click_with_signature') }
    let(:expected_signature) { example_payload['headers']['X-Mandrill-Signature'] }
    let(:original_url) { example_payload['original_url'] }
    let(:webhook_key) { example_payload['private_key'] }
    let(:params) { example_payload['raw_params'] }
    subject { processor_class.generate_signature(webhook_key, original_url, params) }
    it "matches expected signature" do
      expect(subject).to eql(expected_signature)
    end
  end

end
