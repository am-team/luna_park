# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.11.3] - 2021-09-02
Added 
- new mapper `Mappers::Codirectionsl` with DSL

## [0.11.2] - 2021-09-01
Added 
- Github CI

## [0.11.1] - 2021-05-24
Added
- Inheritance of `Extensions::Injector`
- Guard and meaningfull exceptions for `Extensions::Injector`
- nil dependencies caching for `Extensions::Injector`
- `Http::Client` can accept no-response
Changed
- `Forms::Simple` now has default behavior of `#perform`, that returns valid params

## [0.11.0] - 2021-03-18
Changed
- Rename Interactors to UseCases
- Rename Errors::Adaptive to Errors:Base 
- Rename Errors::Processing to Errors::Business
Added
- Add class Errors::System
- Add class UseCase::Service
- Add class Extensions::HasError
Removed
- `on_error action:` instead of use Errors::Business and Errors::System directly

## [0.10.8] - 2021-02-09
Added
- Add sentry notifier

## [0.10.7] - 2021-02-05
Fixed
- Errors::Processing now has right default `notify` and `on_error`

## [0.10.5] - 2021-01-15
Added
- Errors::Adaptive configurations like .message, .on_error will work with inheritance now

## [0.10.5] - 2021-01-15
Added
- default message in Errors::Adaptive now can be generated with details usage, when message defined with block
```
class WrongAnswerError < LunaPark::Errors::Adaptive
  message { |d| "Answer is `#{d[:correct]}` - not `#{d[:wrong]}`" }
end
```
- i18n messages in Errors::Adaptive now can use i18n interpolation
```
de:
  errors:
    wrong_answer: Die richtige Antwort ist %{correct}, nicht %{wrong}
```

## [0.10.4] - 2020-11-16
Added
- Add injector method

## [0.10.0] - 2020-09-22
Added
- Add adaptive errors
- Add new http client
- Add new type of interactor - Scenario
- Add new pattern Notifier, with logger & bugsnag implementation
- Add new extensions of repositories: CRUD
- Add `rake console` command
Fixed
- Codependent gems can be requested if they are installed with the correct version number

## [0.9.0]
Was experimental and didn't make it to the master branch

## [0.8.5] - 2019-07-12
Added
- Extensions::Attributable and Extensions::Serializable now can not duplicate attribute names

## [0.8.4] - 2019-07-10
Added
- Extensions::Exceptions::Substitutive, that allows you to substitute
  origin exception with custom exception and save backtrace of origin.
  In other case information of origin exception will be losed,
  that can be very painfull when something goes wrong.

## [0.8.3] - 2019-07-10
Added
- method Interactors::Sequence#failure that returns catched Processing exception object

## [0.8.1] - 2019-06-18
Added
- Extensions::DataMapper for implement Repository for concrete Entity
- Repositories::Sequel that uses Extensions::DataMapper

## [0.8.0] - 2019-06-17
Update dry validations 0.13 to 1.1

## [0.7.0] - 2019-05-30
Simplify interactors

### Changed
- UseCases::Service - removed, instead of this methods use
`extend Extensions::Callable` or `LunaPark::Callable`
```ruby
# Deprecated
class YourService < LunaPark::UseCases::Service
  private
  def execute
    # your logic there
  end
end

# Use
class YourService
  extend Extensions::Callable

  def call
    # your logic there
  end
end

# Or

class YourService < LunaPark::Callable
  def call
    # your logic there
  end
end
```

- UseCases::Command - removed, instead of this methods use
`extend Extensions::Callable` or `LunaPark::Callable`
```ruby
# Deprecated
class YourCommand < LunaPark::UseCases::Command
  private
  def execute
    # your logic there
  end
end

# Use
class YourCommand
  extend Extensions::Callable

  def call
    # your logic there
    true
  end
end

# Or

class YourCommand < LunaPark::Callable
  def call
    # your logic there
    true
  end
end
```

- method `execute` at `Interactors::Sequnce` is removed, instead of this methods use `call!`

- method `returned_data` is removed, instead of this methods return data at `call!`

```ruby
# Deprecated
class YourSequence < LunaPark::Intractors::Sequence
  private
  def execute
    # your logic there
  end

  def returned_data
    { foo: :bar }
  end
end

# Use
class YourSequence < LunaPark::Intractors::Sequence
  def call!
    # your logic there
    { foo: :bar }
  end
end
```

# Added
- callback method `on_fail` at `Interactors::Sequence`

```ruby
class YourSequence < LunaPark::Intractors::Sequence
  def call!
    raise Errors::Processing
  end

  private

  def on_fail
    puts 'foobar'
  end
end

i = YourSequence.call

#=> foobar

```

## [0.6.2] - 2019-05-03
### Changed
- Extensions::Attributable now uses `#each_pair` instead of `#each`

## [0.6.1] - 2019-04-17
- DSL `.fk`, `.foreign_key` method now can be reloaded with usage `super` (before the `super` was not available)

## [0.6.0] - 2019-04-17
### Internal changes
Moved to modules:
- Extensions::Wrappable adds `.wrap`
- Extensions::Serializable adds `#to_h` and `#serialize` as alias
- Extensions::Comparable adds `#==` and `#eql?`
- Extensions::Dsl::Attributes adds `.attr .attrs .attr? .attrs?` DSL methods
  - optionaly works in synergy with Extensions::Serializable and Extensions::Comparable

### Added
- YARDoc
- Extensions::Dsl::ForeignKey adds `.foreign_key` for create foreign key accessor with ergonomically-related object acessor. Has `.fk` as shorter variant (not alias)
- Entities::Attributable (Entities::Simple with included Extensions::Comparable, Extensions::Serializable, Extensions::Dsl::Attributes)
- Values::Attributable (Values::Simple with included Extensions::Comparable, Extensions::Serializable, Extensions::Dsl::Attributes)
- DSL `.attr` can create typed arrays by option `array: true`
- Some meaningfull exceptions when library used wrong
- Extensions::ComparableDebug#detailed_differences method that returns only differences
  (#differences_structure renamed to #detailed_comparsion with alias #detailed_cmp)
- Extensions::Comparable adds `#enable_debug` and `.enable_debug` that just includes `Extensions::ComparableDebug` to current class
  has aliases `#debug`, `.debug`
- Extensions::PredicateAttribute adds `#predicate_attr_reader`, `#predicate_attr_accessor` and aliased `#attr_reader?`, `#artr_accessor?`
- Extensions::TypedAttribute adds `#typed_attr_writer`, `#typed_attr_accessor`

### Fixed
- DSL `.namespace` method now can be reloaded with using `super` (before the `super` was not available)
- `#to_h`, `#==` from Extensions::Serializable and Extensions::Comparable now works fine in inverited classes
- Values::Single now will be serialized too when you will try send #to_h to aggregate, included Values::Single instance

### Changed
- ComparableDebug#detailed_comparsion renamed from #differences_structure.
  (Now available: #detailed_differences and #detailed_comparsion
  with aliases: #detailed_diff and #detailed_cmp)

## [0.5.9] - 2019-04-09
### Added
- `Extensions::Validateable::Dry` - same as normal `Validateable`, but method `.validator` can receive block
	  to create anonymous validator `Validator::Dry` (block will be passed to .validation_schema of new validator)
- `Extensions::Validateable.validator` now can be setter (when arguments given) and getter (without args)

## [0.5.8] - 2019-04-09
### Changed
- Validateable renamed to Validatable (without backward compatibility)
- Validator`#valid?` DEPRECATED, use `#success?` instead
- Validator`#validation_errors?` DEPRECATED, use `#errors` instead

### Added
- Extensions::Validatable`#valid?` `#validation_errors` `#valid_params` now can work without defined `.validator`

## [0.5.7] - 2019-03-20
### Added
- `Forms::Simple`

## [0.5.6] - 2019-03-19
### Added
- Form example comment

### Changed
- `Form#complete!` renamed to `#submit` (#complete! removed)
- `Validatable#validate!` removed

## [0.5.5] - 2019-03-13
### Added
- LunaPark::Mappers::Simple

### Changed
- LunaPark::Extensions::Attributable#set_attributes now returns `self` - not given Hash

## [0.5.4] - 2019-02-05
### Added
- Change error message for `.wrap` from `Can't wrap OtherClass` to `MyClass can't wrap OtherClass`

## [0.5.1] - 2018-01-14
### Added
- This CHANGELOG
- Renamed ValueObject::Simple -> ValueObject::Single

### Changed
- RUS Guideline: Entity - improve orthography and punctuation
- RUS Guideline: Value  - improve orthography and punctuation
- RUS Guideline: Way    - improve orthography and punctuation

## [0.5.0] - 2018-12-30
### Added
- Nested Entity
- Simple Entity
- Single item Form
- Simple Handler
- Sequence Interactor
- Simple Serializer
- Service Use Case
- Command Use Case
- Dry Validator
- Compound Value
- Single Value
- RUS Guideline: Implementation area
- RUS Guideline: Methodology
- RUS Guideline: Architecture
- RUS Guideline: The Way
- RUS Guideline: ValueObject
- RUS Guideline: Entity
- RUS Guideline: Sequence
- RUS Guideline: Services
- RUS Guideline: Value
