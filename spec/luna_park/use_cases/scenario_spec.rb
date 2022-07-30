# frozen_string_literal: true

require 'i18n'
I18n.load_path << Dir['spec/locales/*.yml']

require 'luna_park/errors/system'
require 'luna_park/errors/business'
require 'luna_park/use_cases/scenario'

class YouDied < LunaPark::Errors::Business
  message 'Always something went wrong', i18n: 'errors.you_die'
end

class ShootInFoot < LunaPark::Errors::System
  message 'Dont use ruby', i18n: 'errors.shoot_in_the_foot'
end

module LunaPark
  RSpec.describe UseCases::Scenario do
    let(:gunshot) do
      Class.new(described_class) do
        attr_accessor :lucky_mode, :error

        def call!
          raise error unless lucky_mode

          'Good day for you'
        end
      end
    end

    let(:scenario) { gunshot.new lucky_mode: true, error: YouDied.new(notify: :info) }

    it 'should has errors' do
      expect(scenario).to be_a Extensions::HasErrors
    end

    describe '#state' do
      subject(:state) { scenario.state }

      context 'before scenario executed' do
        it { is_expected.to eq :initialized }
      end

      context 'on call!' do
        it { expect { scenario.call! }.not_to change { state } }
      end

      context 'on .call ' do
        context 'when scenario succeed' do
          it { expect { scenario.call }.to change { scenario.state }.from(:initialized).to(:success) }
        end

        context 'when scenario has business error' do
          let(:scenario) { gunshot.new lucky_mode: false, error: YouDied.new }
          it { expect { scenario.call }.to change { scenario.state }.from(:initialized).to(:fail) }
        end
      end
    end

    describe '#failure' do
      subject(:failure) { scenario.failure }
      it { is_expected.to be_nil }

      context 'on .call ' do
        before { scenario.call }

        context 'when scenario succeed' do
          let(:scenario) { gunshot.new lucky_mode: true }
          it { is_expected.to be_nil }
        end

        context 'when scenario has business error' do
          let(:scenario) { gunshot.new lucky_mode: false, error: YouDied.new }
          it { is_expected.to be_an_instance_of YouDied }
        end
      end
    end

    describe '#data' do
      subject(:data) { scenario.data }

      context 'before scenario executed' do
        it { is_expected.to be_nil }
      end

      context 'after call!' do
        before { scenario.call! }
        it { is_expected.to be_nil }
      end

      context 'after .call ' do
        before { scenario.call }

        context 'when scenario succeed' do
          let(:scenario) { gunshot.new lucky_mode: true, error: YouDied.new }
          it { is_expected.to eq 'Good day for you' }
        end

        context 'when scenario has business error' do
          let(:scenario) { gunshot.new lucky_mode: false, error: YouDied.new }
          it { is_expected.to be_nil }
        end
      end
    end

    describe '#locale' do
      subject(:locale) { scenario.locale }

      context 'locale is not defined' do
        it { is_expected.to eq nil }
      end

      context 'locale is defined on initialization scenario object' do
        let(:scenario) { gunshot.new locale: :ru }

        it 'should be eq defined locale' do
          is_expected.to eq :ru
        end
      end
    end

    describe '#.call!' do
      subject(:call!) { scenario.call! }

      context 'when scenario succeed' do
        let(:scenario) { gunshot.new lucky_mode: true }

        it 'return defined value' do
          is_expected.to eq 'Good day for you'
        end
      end

      context 'when scenario failed' do
        let(:scenario) { gunshot.new lucky_mode: false, error: YouDied.new }

        it { expect { call! }.to raise_error YouDied }
      end
    end

    describe '#call' do
      subject(:call) { scenario.call }

      context 'when scenario succeed' do
        let(:scenario) { gunshot.new lucky_mode: true }

        it 'return the same scenario' do
          is_expected.to eq scenario
        end
      end

      context 'when scenario failed' do
        context 'as business error' do
          let(:scenario) { gunshot.new lucky_mode: false, error: YouDied.new }

          it 'return the same scenario' do
            is_expected.to eq scenario
          end
        end

        context 'is system error' do
          let(:scenario) { gunshot.new lucky_mode: false, error: ShootInFoot.new }

          it 'is expected to raise defined error' do
            expect { call }.to raise_error ShootInFoot
          end
        end
      end

      describe 'notify parameter' do
        let(:notifier) { double('Notifier', error: nil, warning: nil, info: nil) }
        let(:scenario) { gunshot.new lucky_mode: false, notifier:, error: YouDied.new(notify:) }

        context 'when it undefined' do
          let(:notify) { nil }

          it 'should not notify' do
            expect(notifier).to_not receive(:post)
            call
          end
        end

        context 'when it disabled' do
          let(:notify) { false }

          it 'should not notify' do
            expect(notifier).to_not receive(:post)
            call
          end
        end

        context 'when it enabled' do
          let(:notify) { true }

          it 'should notify error lvl message' do
            expect(notifier).to receive(:post).with(instance_of(YouDied), lvl: :error)
            call
          end
        end

        context 'when it set to unknown lvl' do
          let(:notify) { :unknown }

          it 'should notify error lvl message' do
            expect(notifier).to receive(:post).with(instance_of(YouDied), lvl: :unknown)
            call
          end
        end

        context 'when it set to fatal lvl' do
          let(:notify) { :fatal }

          it 'should notify error lvl message' do
            expect(notifier).to receive(:post).with(instance_of(YouDied), lvl: :fatal)
            call
          end
        end

        context 'when it set to error lvl' do
          let(:notify) { :error }

          it 'should notify error lvl message' do
            expect(notifier).to receive(:post).with(instance_of(YouDied), lvl: :error)
            call
          end
        end

        context 'when it set to warning lvl' do
          let(:notify) { :warning }

          it 'should notify error lvl message' do
            expect(notifier).to receive(:post).with(instance_of(YouDied), lvl: :warning)
            call
          end
        end

        context 'when it set to info lvl' do
          let(:notify) { :info }

          it 'should notify info lvl message' do
            expect(notifier).to receive(:post).with(instance_of(YouDied), lvl: :info)
            call
          end
        end

        context 'when it set to debug lvl' do
          let(:notify) { :debug }

          it 'should notify debug lvl message' do
            expect(notifier).to receive(:post).with(instance_of(YouDied), lvl: :debug)
            call
          end
        end
      end
    end

    describe '#notifier' do
      subject(:notifier) { scenario.notifier }

      context 'when notifier does not set in class or instance' do
        it 'should eq default notifier' do
          is_expected.to eq described_class.default_notifier
        end
      end

      context 'when notifier defined in class' do
        let!(:notifier) { stub_const('Notifier', Class.new) }

        let(:gunshot) do
          Class.new(described_class) do
            attr_accessor :notify, :lucky_mode, :error

            notify_with notifier
          end
        end

        it 'should eq class defined notifier' do
          is_expected.to eq notifier
        end
      end

      context 'when notifier does not set in instance' do
        let(:notifier) { double 'Notifier' }
        let(:scenario) { gunshot.new notifier: }

        it 'should eq defined notifier' do
          is_expected.to eq notifier
        end
      end
    end

    describe '#fail?' do
      subject(:fail?) { scenario.fail? }

      context 'before scenario executed' do
        it { is_expected.to eq false }
      end

      context 'on call!' do
        it { expect { scenario.call! }.not_to change { scenario.fail? } }
      end

      context 'on .call ' do
        context 'when scenario succeed' do
          it { expect { scenario.call }.not_to change { scenario.fail? } }
        end

        context 'when scenario failed' do
          let(:scenario) { gunshot.new lucky_mode: false, error: YouDied.new }
          it { expect { scenario.call }.to change { scenario.fail? }.from(false).to(true) }
        end
      end
    end

    describe '#success?' do
      subject(:success?) { scenario.success? }

      context 'before scenario executed' do
        it { is_expected.to eq false }
      end

      context 'on call!' do
        it { expect { scenario.call! }.not_to change { scenario.success? } }
      end

      context 'on .call ' do
        context 'when scenario succeed' do
          it { expect { scenario.call }.to change { scenario.success? }.from(false).to(true) }
        end

        context 'when scenario failed' do
          let(:scenario) { gunshot.new lucky_mode: false, error: YouDied.new }
          it { expect { scenario.call }.not_to change { scenario.success? } }
        end
      end
    end

    describe '#failure_message' do
      subject(:failure_message) { scenario.failure_message }
      it { is_expected.to be_nil }

      context 'on .call ' do
        before { scenario.call }

        context 'when scenario succeed' do
          let(:scenario) { gunshot.new lucky_mode: true }
          it { is_expected.to be_nil }
        end

        context 'when scenario failed' do
          context 'as business error' do
            context 'on default locale' do
              let(:scenario) { gunshot.new lucky_mode: false, error: YouDied.new }

              it 'should use default locale' do
                is_expected.to eq 'You die'
              end
            end

            context 'on defined locale in object' do
              let(:scenario) { gunshot.new lucky_mode: false, error: YouDied.new, locale: :ru }
              it 'should use object locale' do
                is_expected.to eq 'Всего лишь царапина'
              end
            end

            context 'on defined locale in object and defined locale in method' do
              let(:scenario) { gunshot.new lucky_mode: false, error: YouDied.new, locale: :ru }
              subject(:failure_message) { scenario.failure_message locale: :fr }

              it 'should use method locale' do
                is_expected.to eq 'Tu merus'
              end
            end
          end
        end
      end
    end

    describe '.default_notifier' do
      subject(:notifier) { gunshot.default_notifier }

      context 'when notifier does not set in class' do
        it { is_expected.to be_an_instance_of Notifiers::Log }
      end

      context 'when notifier defined in class' do
        let!(:notifier) { stub_const('Notifier', Class.new) }

        let(:gunshot) do
          Class.new(described_class) do
            attr_accessor :notify

            notify_with Notifier
          end
        end

        it 'should eq class defined notifier' do
          is_expected.to eq Notifier
        end
      end
    end
  end
end
