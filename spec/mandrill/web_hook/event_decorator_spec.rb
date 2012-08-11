require 'spec_helper'

describe Mandrill::WebHook::EventDecorator do


  let(:event_payload) { Mandrill::WebHook::EventDecorator[raw_event] }
  subject { event_payload }

  context "with 'inbound' event_type" do

    let(:event_type) { 'inbound' }
    let(:subject_line) { 'a subject line' }
    let(:sender_email) { 'test@example.com' }
    let(:message_text) { "raw message text\n\n" }
    let(:message_html) { "<div>some content</div>" }
    let(:message_raw) { "the raw message text" }
    let(:message_id) { "1234567890" }

    let(:raw_event) { {
      'event' => event_type,
      'msg' => {
        'from_email' => sender_email,
        'subject' => subject_line,
        'headers' => {
          'Cc' => "c@example.com,b@example.com",
          'Message-Id' => message_id
        },
        'html' => message_html,
        'raw_msg' => message_raw,
        'text' => message_text,
        'cc' => [ [ "c@example.com", "C"],[ "b@example.com", nil] ],
        'to' => [ [ "a@example.com", "A"],[  "b@example.com", nil] ]
      }
    } }

    its(:event_type) { should eql(event_type) }
    its(:subject) { should eql(subject_line) }
    its(:sender_email) { should eql(sender_email) }
    its(:recipients) { should eql([["a@example.com", "A"], ["b@example.com", nil], ["c@example.com", "C"]]) }
    its(:message_id) { should eql(message_id) }

    describe "#recipient_emails" do
      its(:recipient_emails) { should eql(["a@example.com", "b@example.com", "c@example.com"]) }
      context "when no to or Cc elements" do
        let(:raw_event) { {} }
        its(:recipient_emails) { should eql([]) }
      end
    end

    describe "#message_body" do
      subject { event_payload.message_body(format) }
      describe ":text" do
        let(:format) { :text }
        it { should eql(message_text) }
      end
      describe ":html" do
        let(:format) { :html }
        it { should eql(message_html) }
      end
      describe ":raw" do
        let(:format) { :raw }
        it { should eql(message_raw) }
      end
    end

  end


  # TODO: elaborate specs for send web hook (need some real payload examples)
  context "with 'send' event_type" do
    let(:event_type) { 'send' }
    let(:subject_line) { 'a subject line' }
    let(:raw_event) { {
      'event' => event_type,
      'subject' => subject_line
    } }

    its(:event_type) { should eql(event_type) }
    its(:subject) { should eql(subject_line) }
  end

  # TODO: other web hook types
  # send - message has been sent
  # hard_bounce - message has hard bounced
  # soft_bounce - message has soft bounced
  # open - recipient opened a message; will only occur when open tracking is enabled
  # click - recipient clicked a link in a message; will only occur when click tracking is enabled
  # spam - recipient marked a message as spam
  # unsub - recipient unsubscribed
  # reject - message was rejected
end