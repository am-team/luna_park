# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.6.0] - 2019-03-23
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
- DSL `.attr` can create coercible arrays by option `array: true`
- DSL `.attr` can create private setter by option `private_setter: true`
- Some meaningfull exceptions when library used wrong
- Extensions::ComparableDebug#detailed_differences method that returns only differences
  (#differences_structure renamed to #detailed_comparsion with alias #detailed_cmp)
- Extensions::Comparable adds `#enable_debug` and `.enable_debug` that just includes `Extensions::ComparableDebug` to current class
  has aliases `#debug`, `.debug`
- Extensions::PredicateAttribute adds `#predicate_attr_reader`, `#predicate_attr_accessor` and aliased `#attr_reader?`, `#artr_accessor?`
- Extensions::CoercibleAttribute adds `#coercible_attr_writer`, `#coercible_attr_accessor`

### Fixed
- DSL `.attr .attrs .attr? .attrs? .namespace` method now can be reloaded with using `super` (before the `super` was not available)
- `#to_h`, `#==` from Extensions::Serializable and Extensions::Comparable now works fine in inverited classes
- Values::Single now will be serialized too when you will try send #to_h to aggregate, included Values::Single instance

### Changed
- ComparableDebug#detailed_comparsion renamed from #differences_structure.
  (Now available: #detailed_differences and #detailed_comparsion
  with aliases: #detailed_diff and #detailed_cmp)

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
