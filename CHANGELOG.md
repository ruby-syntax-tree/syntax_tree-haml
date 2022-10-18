# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.0.0] - 2022-10-18

### Added

- Support for Ruby 2.7.0, not just 2.7.3
- Require syntax_tree 4.0.1 or higher.
- Require prettier_print 1.0.0 or higher.

### Changed

- Nodes must now be formatted with a `SyntaxTree::Haml::Formatter`.

## [1.3.2] - 2022-09-19

### Added

- Properly support unescaping plain and script.

## [1.3.1] - 2022-08-01

### Changed

- Use Syntax Tree to handle properly quoting strings.

## [1.3.0] - 2022-07-22

### Added

- Support changing the preferred quote through the single quotes plugin.

## [1.2.1] - 2022-07-22

### Changed

- Fix formatting for when empty `%div` or `%div` with no attributes and just children is present.

## [1.2.0] - 2022-05-13

### Added

- An optional `maxwidth` second argument to `SyntaxTree::Haml.format`.

## [1.1.0] - 2022-04-22

### Added

- Support for Ruby 2.7 added back.

## [1.0.1] - 2022-03-31

### Changed

- Fix up usage of the `SyntaxTree.register_handler` method.

## [1.0.0] - 2022-03-31

### Changed

- Hook into Syntax Tree 2.0.0 to provide CLI support.

## [0.1.0] - 2022-03-31

### Added

- 🎉 Initial release! 🎉

[unreleased]: https://github.com/ruby-syntax-tree/syntax_tree-haml/compare/v2.0.0...HEAD
[2.0.0]: https://github.com/ruby-syntax-tree/syntax_tree-haml/compare/v1.3.2...v2.0.0
[1.3.2]: https://github.com/ruby-syntax-tree/syntax_tree-haml/compare/v1.3.1...v1.3.2
[1.3.1]: https://github.com/ruby-syntax-tree/syntax_tree-haml/compare/v1.3.0...v1.3.1
[1.3.0]: https://github.com/ruby-syntax-tree/syntax_tree-haml/compare/v1.2.1...v1.3.0
[1.2.1]: https://github.com/ruby-syntax-tree/syntax_tree-haml/compare/v1.2.0...v1.2.1
[1.2.0]: https://github.com/ruby-syntax-tree/syntax_tree-haml/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/ruby-syntax-tree/syntax_tree-haml/compare/v1.0.1...v1.1.0
[1.0.1]: https://github.com/ruby-syntax-tree/syntax_tree-haml/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/ruby-syntax-tree/syntax_tree-haml/compare/v0.1.0...v1.0.0
[0.1.0]: https://github.com/ruby-syntax-tree/syntax_tree-haml/compare/c1264c...v0.1.0
