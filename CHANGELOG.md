# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [4.0.3] - 2023-03-12

### Changed

- Fixed a bug where blank lines were being inserted into filter nodes accidentally.

## [4.0.2] - 2023-03-09

### Changed

- Require `prettier_print` `1.2.1` or higher to fix the infinite loop bug.
- Maintain blank lines in nested nodes.

## [4.0.1] - 2023-03-07

### Changed

- We now keep blank lines around in the source template. (Multiple blank lines are squished down to a single blank line.)
- We now actually parse the Ruby code written in `%=` tags. This fixed a couple of bugs and allows us to better format the output. For example, `%p= 1+1` will now be formatted as `%p= 1 + 1`. If the output fails to parse it falls back to the previous behavior of just printing the Ruby code as-is.

## [4.0.0] - 2023-03-07

### Changed

- Required syntax_tree version 6.0.0 or higher.
- Fixed up hash attribute parser to handle multiline hashes using Syntax Tree itself.

## [3.0.0] - 2022-12-23

### Changed

- Required syntax_tree version 5.0.1 or higher.
- Drop internal pattern matching in order to support Ruby implementations that don't support it.

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

[unreleased]: https://github.com/ruby-syntax-tree/syntax_tree-haml/compare/v4.0.3...HEAD
[4.0.3]: https://github.com/ruby-syntax-tree/syntax_tree-haml/compare/v4.0.2...v4.0.3
[4.0.2]: https://github.com/ruby-syntax-tree/syntax_tree-haml/compare/v4.0.1...v4.0.2
[4.0.1]: https://github.com/ruby-syntax-tree/syntax_tree-haml/compare/v4.0.0...v4.0.1
[4.0.0]: https://github.com/ruby-syntax-tree/syntax_tree-haml/compare/v3.0.0...v4.0.0
[3.0.0]: https://github.com/ruby-syntax-tree/syntax_tree-haml/compare/v2.0.0...v3.0.0
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
