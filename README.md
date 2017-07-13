## LPSnackbar


<p align="center">
<img src="https://raw.githubusercontent.com/luispadron/LPSnackbar/master/.github/Screen1.png"/>  
</p>

## Features 

- Flexible, easy to use and customizable.
- _Snacks_ are actionable.
	
	<img src="https://raw.githubusercontent.com/luispadron/LPSnackbar/master/.github/Demo1.gif" width="350"/>  
	
- _Snacks_ are stackable and swipeable.
	
	<img src="https://raw.githubusercontent.com/luispadron/LPSnackbar/master/.github/Demo2.gif" width="350"/>  

- Supports iOS 8.0 +
- Written with the latest Swift (Swift 4)

## Installation

### Cocoapods (recommended)

1. Install [CocoaPods](https://cocoapods.org).
2. Add this pod to your `Podfile`.

	```ruby
	target 'Example' do
		use_frameworks!

		pod 'LPSnackbar'
	end
	```
3. Run `pod install`.
4. Open up the `.xcworkspace` that CocoaPods created.
5. Import `LPSnackbar` into any source file where it's needed.

### From Source

1. Simply download the source from [here](https://github.com/luispadron/LPSnackbar/tree/master/LPSnackbar) and add it to your Xcode project.


## Usage

Snacks can be simple

```swift
// Yes, this simple.
LPSnackbar.showSnack(title: "I'm a snack!")
```

Snacks can be customized

```swift
let snack = LPSnackbar(title: "Object deleted.", buttonTitle: "UNDO")
// Customize the snack
snack.bottomSpacing = (tabBarController?.tabBar.frame.height ?? 0) + 15
snack.view.titleLabel.font = UIFont.systemFont(ofSize: 20)

// Show a snack to allow user to undo deletion
snack.show(animated: true) { (undone) in
    if undone {
		// Undo deletion
    } else {
		// Follow through with deletion
    }
}
```

## Example

Download and run the example project

## Documentation

Full documentation available [here](https://htmlpreview.github.io/?https://github.com/luispadron/LPSnackbar/blob/master/docs/index.html)
