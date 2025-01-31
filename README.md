# Mandrill::Rails

The primary goal of Mandrill::Rails is to make supporting Mandrill web hooks as easy and Rails-native as possible. As other opportunities for better Rails integration of the Mandrill API are discovered, these may be rolled in too.

I thought about implementing this as an engine, but the overhead did not seem appropriate. Maybe that view will change..

Mandrill::Rails currently does not need or require any direct Mandrill API integration, such as provided by
various [Mandrill](https://rubygems.org/search?utf8=%E2%9C%93&query=mandrill)
and [MailChimp](https://rubygems.org/search?utf8=%E2%9C%93&query=mailchimp) gems.
If you need direct API integration in addition to Mandrill::Rails features, you can choose to add whichever best meets your needs.

FYI, [Mandrill](http://mandrill.com/) is the transactional email service by the same folks who do MailChimp.

## Requirements and Known Limitations

For Rails 7+, use [Action Mailbox](https://guides.rubyonrails.org/v7.1/action_mailbox_basics.html) instead. Mandrill::Rails is no longer being maintained for newer Rails versions.

Mandrill::Rails 1.5.0+ supports Rails 5 and Rails 6.

For Rails >= 3.0.3, use Mandrill::Rails 1.4.1.

## The Mandrill::Rails Cookbook

### How do I install it for normal use?

Add this line to your application's Gemfile:

    gem 'mandrill-rails'

And then execute:

    bundle

Or install it yourself as:

    gem install mandrill-rails

### How do I install it for gem development?

If you want to work on enhancements or fix bugs in Mandrill::Rails, fork and clone the github repository. If you are using bundler (recommended), run `bundle` to install development dependencies.

Run tests using `rake` or `rake spec`, and note that guard is also included with the development dependencies so
you can kick-off continuous testing of changed files by running `bundle exec guard`.

See the section below on 'Contributing to Mandrill::Rails' for more information.

### How do I configure my app for incoming Mandrill WebHooks?

Say we have configured Mandrill to send requests to /inbox at our site (see the next recipes for how you do that).

Once we have Mandrill::Rails in our project, we just need to do two things. You can run a generator to do it for you, or you can configure things manually:

#### Using the generator

Run the generator and specify the name for your route and controller:

    rails generate mandrill inbox

This will create a resource route and corresponding controller at /inbox.

If you need a namespaced controller, specify it in the name:

    rails generate mandrill hooks/inbox

This creates an `inbox` route that points to the `Hooks:InboxController` class.

If you prefer pluralized names, that can be specified with a flag:

    rails generate mandrill inbox --pluralize_names

This will create an `InboxesController` class and a resource route called `inboxes`.

#### Manual configuration

First, configure a resource route:

    resource :inbox, :controller => 'inbox', :only => [:show,:create]

Next, create the corresponding controller:

    class InboxController < ApplicationController
      include Mandrill::Rails::WebHookProcessor
    end

That's all for the basic do-nothing endpoint setup. Note that we need both the GET and POST routes (Mandrill sends data to the POST route, but it uses GET to test the availability of the endpoint).

You can setup as many of these controllers as you need, if you wish different types of events to be handled by different routes.

### How do I configure Mandrill to send inbound email to my app?

See [Mandrill Inbound Domains](https://mandrillapp.com/inbound)

* enter the mail route you want to match on e.g. *@app.mydomain.com
* set the WebHook enpoint to match e.g. <http://mydomain.com/inbox>

### How do I configure Mandrill to send WebHook requests to my app?

See [Mandrill WebHooks](https://mandrillapp.com/settings/webhooks)

* select the events you want to trigger on
* set the "Post to URL" to point to your controller e.g. <http://mydomain.com/inbox>

### How do I handle specific Mandrill event payloads in my app?

Once we have configured Mandrill and setup our routes and controllers, our app will successfully
receive WebHook event notifications from Mandrill. But we are not doing anything with the payload yet.

To handle specific Mandrill event payloads, we just need to implement a handler for each event type
we are interested in.

The list of available event types includes: inbound, send, hard_bounce, soft_bounce, open,
click, spam, unsub, and reject.

In our controller, we simply write a method called `handle_<event-type>` and it will be called
for each event payload received. The event payload will be passed to this method
as a Mandrill::WebHook::EventDecorator - basically a Hash with some additional methods to
help extract payload-specific elements.

For example, to handle inbound email:

    class InboxController < ApplicationController
      include Mandrill::Rails::WebHookProcessor

      def handle_inbound(event_payload)
        Item.save_inbound_mail(event_payload)
      end

    end

If the handling of the payload may be time-consuming, you could throw it onto a background
queue at this point instead.

Note that Mandrill may send multiple event payloads in a single request, but you don't need
to worry about that. Each event payload will be unpacked from the request and dispatched to
your handler individually.

### Do I need to handle all the event payloads that Mandrill send?

No. It is optional. If you don't care to handle a specific payload type - then just don't implement the associated handler method.

For example, your code in production only has a `handle_inbound` method, but you turn on click webhooks. What should happen?

By default, click events will simply be ignored and logged (as errors) in the Rails log.

You can change this behaviour. To completely ignore unhandled events (not even logging), add the `ignore_unhandled_events!`
directive to your controller:

    class InboxController < ApplicationController
      include Mandrill::Rails::WebHookProcessor
      ignore_unhandled_events!
    end

At the other extreme, if you want unhandled events to raise a hard exception, add the `unhandled_events_raise_exceptions!`
directive to your controller:

    class InboxController < ApplicationController
      include Mandrill::Rails::WebHookProcessor
      unhandled_events_raise_exceptions!
    end

### How can I authenticate Mandrill Webhooks?

Mandrill now supports [webhook authentication](http://help.mandrill.com/entries/23704122-Authenticating-webhook-requests) which can help prevent unauthorised posting to your webhook handlers. You can lookup and reset your API keys on the
[Mandrill WebHook settings](https://mandrillapp.com/settings/webhooks) page.

If you do not configure your webhook API key, then the handlers will continue to work fine - they just won't be authenticated.

To enable authentication, use the `authenticate_with_mandrill_keys!` method to set your API key. It is recommended you pull
your API keys from environment settings, or use some other means to avoid committing the API keys in your source code.

For example, to handle inbound email:

    class InboxController < ApplicationController
      include Mandrill::Rails::WebHookProcessor
      authenticate_with_mandrill_keys! 'YOUR_MANDRILL_WEBHOOK_KEY'

      def handle_inbound(event_payload)
        # .. handler methods will only be called if authentication has succeeded.
      end

    end

### How can I authenticate multiple Mandrill Webhooks in the same controller?

Sometimes you may have more than one WebHook sending requests to a single controller, for example if you have one handling 'click' events, and another sending inbound email. Mandrill assigns separate API keys to each of these.

In this case, just add all the valid API keys you will allow with `authenticate_with_mandrill_keys!`, for example:

    class InboxController < ApplicationController
      include Mandrill::Rails::WebHookProcessor
      authenticate_with_mandrill_keys! 'MANDRILL_CLICK_WEBHOOK_KEY', 'MANDRILL_INBOUND_WEBHOOK_KEY', 'ANOTHER_WEBHOOK_KEY'

      def handle_inbound(event_payload)
      end

      def handle_click(event_payload)
      end

    end

### How do I pull apart the event_payload?

The `event_payload` object passed to our handler represents a single event and is packaged
as an Mandrill::WebHook::EventDecorator - basically a Hash with some additional methods to
help extract payload-specific elements.

You can use it as a Hash (with String keys) to access all of the native elements of the specific event, for example:

    event_payload['event']
    => "click"
    event_payload['ts']
    => 1350377135
    event_payload['msg']
    => {...}

If you would like examples of the actual data structures sent by Mandrill for different event types,
some are included in the project source under spec/fixtures/webhook_examples.

### What additional methods does event_payload provide to help extract payload-specific elements?

In addition to providing full Hash-like access to the raw message, the `event_payload` object
(a Mandrill::WebHook::EventDecorator) provides a range of helper methods for some of the more obvious
things you might need to do with the payload. Here are some examples (see
[Mandrill::WebHook::EventDecorator class documentation](http://rubydoc.info/gems/mandrill-rails/Mandrill/WebHook/EventDecorator)
for full details)

    event_payload.message_id
    # Returns the message_id.
    # Inbound events: references 'Message-Id' header.
    # Send/Open/Click events: references '_id' message attribute.

    event_payload.user_email
    # Returns the subject user email address.
    # Inbound messages: references 'email' message attribute (represents the sender).
    # Send/Open/Click messages: references 'email' message attribute (represents the recipient).

    event_payload.references
    # Returns an array of reference IDs.
    # Applicable events: inbound

    event_payload.recipients
    # Returns an array of all unique recipients (to/cc)
    #   [ [email,name], [email,name], .. ]
    # Applicable events: inbound

    event_payload.recipient_emails
    # Returns an array of all unique recipient emails (to/cc)
    #   [ email, email, .. ]
    # Applicable events: inbound

### How to extend Mandrill::WebHook::EventDecorator for application-specific payload handling?

It's likely you may benefit from adding more application-specific intelligence to the
`event_payload` object.

There are many ways to do this, but it is quite legitimate to reopen the EventDecorator class and add your own methods
if you wish.

For example `event_payload.user_email` returns the subject user email address, but perhaps I will commonly want to
match that with a user record in my system. Or I similarly want to resolve `event_payload.recipient_emails` to user records.
In this case, I could extend EventDecorator in my app like this:

    # Extends Mandrill::WebHook::EventDecorator with app-specific event payload transformation
    class Mandrill::WebHook::EventDecorator

      # Returns the user record for the subject user (if available)
      def user
        User.where(email: user_email).first
      end

      # Returns user records for all to/cc recipients
      def recipient_users
        User.where(email: recipient_emails)
      end

    end

### How do I extract attachments from an inbound email?

The EventDecorator class provides an `attachments` method to access an array of attachments (if any).
Each attachment is encapsulated in a class that describes the name, mime type, raw and decoded content.

For example:

    def handle_inbound(event_payload)
      if attachments = event_payload.attachments.presence
        # yes, we have at least 1 attachment. Lets look at the first:
        a1 = attachments.first

        a1.name
        # => e.g. 'sample.pdf'
        a1.type
        # => e.g. 'application/pdf'
        a1.base64
        # => true
        a1.content
        # => this is the raw content provided by Mandrill, and may be base64-encoded
        # e.g. 'JVBERi0xLjMKJcTl8uXrp/Og0MTGCjQgMCBvY ... (etc)'
        a1.decoded_content
        # => this is the content decoded by Mandrill::Rails, ready to be written as a File or whatever
        # e.g. '%PDF-1.3\n%\xC4\xE5 ... (etc)'

      end
    end

### How do I extract images from an inbound email?

The EventDecorator class provides an `images` method to access an array of images (if any).
Each image is encapsulated in a class that describes the name, mime type, raw and decoded content.

For example:

    def handle_inbound(event_payload)
      if images = event_payload.images.presence
        # yes, we have at least 1 image. Lets look at the first:
        a1 = images.first
        a1.name
        # => e.g. 'sample.png'
        a1.type
        # => e.g. 'image/png'
        a1.base64
        # => true # always
        a1.content
        # => this is the raw content provided by Mandrill (always base64)
        # e.g. 'iVBORw0K ... (etc)'
        a1.decoded_content
        # => this is the content decoded by Mandrill::Rails, ready to be written as a File or whatever
        # e.g. '\x89PNG\r\n ... (etc)'
      end
    end

### How do I use Mandrill API features with Mandrill::Rails?

Mandrill::Rails currently does not need or require any direct Mandrill API integration (such as provided by
various [Mandrill](https://rubygems.org/search?utf8=%E2%9C%93&query=mandrill)
and [MailChimp](https://rubygems.org/search?utf8=%E2%9C%93&query=mailchimp) gems).
If you need direct API integration in addition to Mandrill::Rails features,
you can choose to add whichever best meets your needs and use as normal.

## Contributing to Mandrill::Rails

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the gemspec, Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2012 Paul Gallagher. See LICENSE for further details.
