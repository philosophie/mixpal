require 'spec_helper'

describe Mixpal::Tracker do
  subject { Mixpal::Tracker.new }
  let(:identity) { 'nick' }
  let(:subject_with_identity) { Mixpal::Tracker.new(identity: identity) }

  context 'with configured helper module' do
    before do
      Mixpal.configure do |config|
        config.helper_module = CustomEventsModule
      end
    end

    it 'exposes helper module methods on tracker instance' do
      expect(subject.custom_event).to eq true
    end
  end

  describe '#initialize' do
    it 'creates an empty set of events' do
      expect(subject.events).to eq []
    end

    it 'creates an empty set of user_updates' do
      expect(subject.user_updates).to eq []
    end

    context 'with an :identity arg' do
      subject { subject_with_identity }

      it 'sets the identity' do
        expect(subject.identity).to eq 'nick'
      end
    end
  end

  describe '#register_user' do
    it 'sets the alias_user flag so we render the alias call' do
      subject.register_user(name: 'Nick')
      expect(subject.alias_user).to be_true
    end

    it 'delegates to #update_user for tracking user properties' do
      properties = { name: 'Nick' }
      subject.should_receive(:update_user).with(properties)
      subject.register_user(properties)
    end
  end

  describe '#update_user' do
    it 'instantiates a new User object with properties' do
      properties = { name: 'Nick' }
      Mixpal::User.should_receive(:new).with(properties)
      subject.update_user(properties)
    end

    it 'adds the User to user_updates for rendering later' do
      expect do
        subject.update_user(name: 'Nick')
      end.to change(subject.user_updates, :size).by(1)

      subject.user_updates.first.should be_an_instance_of(Mixpal::User)
    end
  end

  describe '#track' do
    it 'instantiates a new Event object with properties' do
      name = 'Clicked Button'
      properties = { color: 'Green' }

      Mixpal::Event.should_receive(:new).with(name, properties)
      subject.track(name, properties)
    end

    it 'adds the Event to events for rendering later' do
      expect do
        subject.track('Clicked Button', color: 'Green')
      end.to change(subject.events, :size).by(1)

      subject.events.first.should be_an_instance_of(Mixpal::Event)
    end
  end

  describe '#render' do
    it 'outputs script tag' do
      expect(subject.render).to have_tag('script')
    end

    it 'outputs an html safe string' do
      expect(subject.render).to be_html_safe
    end

    context 'with an identity' do
      subject { subject_with_identity }

      it 'outputs call to identify' do
        expect(subject.render).to include "mixpanel.identify(\"#{identity}\");"
      end

      context 'when user is being registered' do
        before { subject.register_user(name: 'Nick Giancola') }

        it 'outputs call to alias by identity' do
          expect(subject.render).to include "mixpanel.alias(\"#{identity}\");"
        end
      end
    end

    context 'with no registered user' do
      it 'does not output call to alias' do
        expect(subject.render).not_to include 'mixpanel.alias'
      end
    end

    context 'without an identity' do
      it 'does not output call to identify' do
        expect(subject.render).not_to include 'mixpanel.indentify'
      end
    end

    context 'with tracked events' do
      before do
        subject.track('Event 1', color: 'Green')
        subject.track('Event 2', title: 'Something Awesome')
      end

      it 'delegates render to the events' do
        subject.events.each { |event| event.should_receive :render }
        subject.render
      end

      it 'joins each rendered event' do
        joined = subject.events[0].render + subject.events[1].render
        expect(subject.render).to include joined
      end
    end

    context 'with user properties' do
      before do
        subject.update_user(name: 'Hank')
        subject.update_user(location: 'Los Angeles')
      end

      it 'delegates render to the users' do
        subject.user_updates.each { |user| user.should_receive :render }
        subject.render
      end

      it 'joins each rendered user' do
        joined = subject.user_updates[0].render + subject.user_updates[1].render
        expect(subject.render).to include joined
      end
    end
  end

  describe '#store!' do
    let(:session) { {} }

    def storage_should_include(hash_fragment)
      expect(session[described_class::STORAGE_KEY]).to include hash_fragment
    end

    it 'stores the alias_user property' do
      subject.register_user({})
      subject.store!(session)
      storage_should_include('alias_user' => true)
    end

    it 'stores the identity' do
      subject_with_identity.store!(session)
      storage_should_include('identity' => identity)
    end

    context 'when events have been tracked' do
      before do
        subject.track('Event 1', color: 'Green')
        subject.track('Event 2', title: 'Something Awesome')
      end

      it 'delegates composition to the events' do
        subject.events.each { |event| event.should_receive :to_store }
        subject.store!(session)
      end

      it 'stores the events composed hashes in an array' do
        subject.store!(session)
        storage_should_include(
          'events' => [subject.events[0].to_store, subject.events[1].to_store]
        )
      end
    end

    context 'when user properties have been updated' do
      before do
        subject.update_user(name: 'Hank')
        subject.update_user(location: 'Los Angeles')
      end

      it 'delegates composition to the users' do
        subject.user_updates.each { |user| user.should_receive :to_store }
        subject.store!(session)
      end

      it 'stores the users composed hashes in an array' do
        subject.store!(session)

        storage_should_include(
          'user_updates' => [
            subject.user_updates[0].to_store,
            subject.user_updates[1].to_store
          ]
        )
      end
    end
  end

  describe '#restore!' do
    let(:old_tracker) { Mixpal::Tracker.new(identity: identity) }
    let(:session) { {} }

    before do
      old_tracker.track 'Event 1'
      old_tracker.register_user name: 'Nick Giancola'
      old_tracker.store!(session)
    end

    it 'restores the alias_user property' do
      subject.restore!(session)
      expect(subject.alias_user).to eq true
    end

    it 'restores the events' do
      subject.restore!(session)
      expect(subject.events.size).to eq 1
    end

    it 'delegates event restoration to the Event class' do
      Mixpal::Event.should_receive(:from_store)
        .with(old_tracker.events.first.to_store)

      subject.restore!(session)
    end

    it 'restores the events' do
      subject.restore!(session)
      expect(subject.events.size).to eq 1
    end

    context 'with a different identity (e.g. after login)' do
      subject { Mixpal::Tracker.new(identity: "#{identity}-2") }

      it 'does not override identity with value in storage' do
        subject.restore!(session)
        expect(subject.identity).to eq "#{identity}-2"
      end
    end

    context 'with no identity (e.g. after logout)' do
      subject { Mixpal::Tracker.new(identity: nil) }

      it 'overrides identity with value in storage' do
        subject.restore!(session)
        expect(subject.identity).to eq identity
      end
    end
  end
end
