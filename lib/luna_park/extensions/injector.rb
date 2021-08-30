# frozen_string_literal: true

require 'luna_park/extensions/injector/dependencies'

module LunaPark
  module Extensions
    # The main goal of the injector is a help developer with
    # dependency injection technique.
    #
    # @example Dependency injection
    #   class Messenger
    #     def self.post(to:, msg:); end
    #   end
    #
    #   module Users
    #     class Entity
    #       def active!; end
    #       def full_name;end
    #     end
    #
    #     class PgRepo
    #       def find(id); end
    #       def save(user); end
    #     end
    #
    #     # In this example, you can see the relationship between
    #     # the business layer and the data layer, and between the
    #     # business layer and external libraries.
    #
    #     class SetActive < LunaPark::UseCases::Scenario
    #       include LunaPark::Extensions::Injector
    #
    #       attr_accessor :user_id
    #
    #       def call!
    #         repo = Users::PgRepo.new # <- dependency from data layer
    #         user = repo.find(user_id)
    #         user.active!
    #         repo.save user
    #
    #         Messenger.post(to: :admin, msg:"User #{user.full_name} is active_now") # <- dependency from external libs
    #       end
    #     end
    #   end
    #
    #   # Here, Injector can help remove the dependency technical details from
    #   # the business layer.
    #
    #   class SetActive < LunaPark::Interactors::Scenario
    #     include LunaPark::Extensions::Injector
    #
    #     dependency(:repo)      { Users::PgRepo.new } # You should define dependency in block - like rspec `let`
    #                                                  # method. That should initialize value only if that needed.
    #     dependency(:messenger) { Messenger }
    #
    #     attr_accessor :user_id
    #
    #     def call!
    #       user = repo.find(user_id)
    #       user.active!
    #       repo.save user
    #
    #       messenger.post(to: :admin, msg:"User #{user.full_name} is active_now")
    #     end
    #   end
    #
    #
    # @example rspec test
    #   module Users
    #     RSpec.describe SetActive do
    #       # We highly dont recommended inject dependencies witch does not call exteranal resources
    #       let(:user)       { Entity.new id: 1, first_name: 'John', last_name: 'Doe'}
    #       let(:use_case) { described_class.new(user_id: 1) }
    #
    #       before do
    #         use_case.dependencies = {
    #           repo: -> { instance_double PgRepo, find: user, save: true },
    #           messenger: -> { class_double Messenger, post: true }
    #         }
    #       end
    #
    #       describe '#call!' do
    #         subject(:set_active!) { use_case.call! }
    #
    #         it 'should set user is active' do
    #           expect{ set_active! }.to change{ user.active? }.from(false).to(true)
    #         end
    #
    #         it 'should save user' do
    #           expect(use_case.repo).to receive(:save).with(user)
    #           set_active!
    #         end
    #
    #         it 'should send expected message to admin' do
    #           text = 'User John Doe is active_now'
    #           expect(use_case.messenger).to receive(:post).with(to: :admin, msg: text)
    #           set_active!
    #         end
    #       end
    #     end
    #   end
    module Injector
      # @!parse include Injector::ClassMethods
      # @!parse extend Injector::InstanceMethods
      def self.included(base)
        base.extend ClassMethods
        base.include InstanceMethods
      end

      module ClassMethods
        def inherited(inheritor)
          dependencies.each_pair do |key, block|
            inheritor.dependency(key, &block)
          end
        end

        ##
        # Set dependency
        #
        # @example Set dependency
        #   class Foo
        #     include LunaPark::Extensions::Injector
        #
        #     dependency(:example) { Bar.new }
        #   end
        def dependency(name, &block)
          raise ArgumentError, 'no block given' unless block_given?

          dependencies[name] = block

          define_method(name) do
            dependencies.call_with_cache(name)
          end
        end

        ##
        # List class defined dependencies
        #
        # @example get dependency
        #  class Foo
        #     include LunaPark::Extensions::Injector
        #
        #     dependency(:example) { Bar.new }
        #   end
        #
        #   Foo.dependencies # => {:example=>#<Proc:0x0000560a4fb48fc0@t.rb:77>}
        def dependencies
          @dependencies ||= {}
        end
      end

      module InstanceMethods
        ##
        # List instance defined dependencies, in default it defined in class
        # methods.
        #
        #   class SetActive
        #     dependency(:repo) { Repo.new(CONFIG[:db_connect]) }
        #     dependency(:messenger) { Messenger }
        #   end
        #
        #   use_case = SetActive.new(user_id: 1)
        #
        #   # All dependencies
        #   use_case.dependencies             # => {
        #                                     #   :repo=>#<Proc:0x0000564a0d90d668@t.rb:33>,
        #                                     #   :messenger=>#<Proc:0x0000564a0d90d438@t.rb:34>
        #                                     # }
        #
        #   # Single dependency
        #   use_case.dependencies[:messenger] # => #<Proc:0x0000564a0d90d438@t.rb:34>
        #
        #   # Dependency value
        #   use_case.messenger                # => Messenger
        def dependencies
          @dependencies ||= Dependencies.wrap(self.class.dependencies)
        end

        ##
        # Setter - highly recommended for use in specs so you don't forget
        # to override <b>all</b> dependencies.
        #
        #   use_case.dependencies = {
        #     repo: -> { Fake::Repo.new }
        #   }
        #   use_case.messenger # => Dependency `messenger` is undefined (LunaPark::Errors::DependencyUndefined)
        #   use_case.call      # => Dependency `messenger` is undefined (LunaPark::Errors::DependencyUndefined)
        #
        #   # Redefine single dependency still possible
        #   use_case.dependencies[:messenger] = -> { Messenger }
        def dependencies=(value)
          @dependencies = Dependencies.wrap(value)
        end
      end
    end
  end
end
