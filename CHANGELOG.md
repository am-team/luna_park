# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.5.9] - 2019-04-09
### Added
- `Extensions::Validateable::Dry` - same as normal `Validateable`, but method `.validator` can receive block
	  to create anonymous validator `Validator::Dry` (block will be passed to .validation_schema of new validator)

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
