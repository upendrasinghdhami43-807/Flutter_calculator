# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
- Setup initial files: README, LICENSE, CONTRIBUTING, CODE_OF_CONDUCT, SECURITY.
- Completed foundation for Phase 3 (Advanced Workbenches).
- Developed `calculus_engine.dart` containing differentiation, numerical integration, and bounded root finding logic.
- Built `ConicSolver` rendering dynamically disconnected geometry using CustomPainter.
- Built interactive function graphing using `InteractiveViewer`.
- Built fast-entry keypad pattern with `GuidedNumberEntrySheet` to optimize array data entries for Matrix and Systems of Equations solving.

## [2.0.0] - Scientific Upgrade 
### Added
- Pro UI Layout (Scientific Calculator).
- Core Expression Evaluator integrating trig functions, standard math operations, parsing complex strings containing `sin()`, `log()`, etc.
- State architecture converted to scalable Riverpod structure.

## [1.0.0] - Initial Release
### Added
- Initial UI structure for the Basic Calculator.
- General operator arithmetic logic.
- Simple history logging and basic thematic switching.