# LPSnackbar CHANGELOG

## Version 1.1.2

- Fix issue where `LPSnackbarView`'s subviews were not accessible with accessibility.

## Version 1.1.1

- Fix bug where `displayTimer` was not being invalidated when calling `dismiss(animated:completeWithAction)`. This bug caused the `SnackbarCompletion` to be called twice.

## Version 1.1.0

- Add `Equatable` conformance to `LPSnackbar`
- Add new parameter to `dismiss(show:)`, `completeWithAction: Bool` which allows you to dismiss the `LPSnackbar` manually while also returning `true` for action in the `SnackbarCompletion`.

## Version 1.0.0

Initial release