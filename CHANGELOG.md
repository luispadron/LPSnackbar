# LPSnackbar CHANGELOG

## Version 2.0.1

- Add support for carthage by updating to `shared` scheme.

## Version 2.0

#### Breaking changes and fixes.
- Fix issue where same snack couldn't be dismissed then shown again. This is now possible.
- Breaking API change to initializer for `LPSnackbar`, the initializers no longer take a `displayDuration`. 
- Removed `displayDuration` member from `LPSnackbar`.
- Add `displayDuration` parameter to the `show()` method, works the same as before, but it is now in a more general place as display duration may now change whenever you present the snack.


## Version 1.1.2

- Fix issue where `LPSnackbarView`'s subviews were not accessible with accessibility.

## Version 1.1.1

- Fix bug where `displayTimer` was not being invalidated when calling `dismiss(animated:completeWithAction)`. This bug caused the `SnackbarCompletion` to be called twice.

## Version 1.1.0

- Add `Equatable` conformance to `LPSnackbar`
- Add new parameter to `dismiss(show:)`, `completeWithAction: Bool` which allows you to dismiss the `LPSnackbar` manually while also returning `true` for action in the `SnackbarCompletion`.

## Version 1.0.0

Initial release