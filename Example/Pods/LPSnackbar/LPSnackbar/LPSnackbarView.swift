//
//  LPSnackbarView.swift
//  LPSnackbar
//
//  Copyright (c) 2017 Luis Padron
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is furnished
//  to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
//  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
//  FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT
//  OR OTHERWISE, ARISING FROM, OUT OF OR IN
//  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import UIKit

/// The `Notification.Name` for when a `LPSnackbarView` has been removed from it's superview.
internal let snackRemoval: Notification.Name = Notification.Name(rawValue: "com.luispadron.LPSnackbar.removalNotification")

/**
 The `LPSnackbarView` which contains 3 subviews.
 
 - titleLabel: The label on the left hand side of the view used to display text.
 
 - button: The button on the right hand side of the view which allows an action to be performed.
 
 - seperator: A small view which adds an accent that seperates the `titleLabel` and the `button`.
 */
open class LPSnackbarView: UIView {
    
    // MARK: Properties
    
    /// The controller for this view
    internal var controller: LPSnackbar?
    
    /// The amount of padding from the left handside, used to layout the `titleLabel`, default is `8.0`
    open var leftPadding: CGFloat = 8.0 {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    /// The amount of padding from the right handside, used to layout the `button`, default is `8.0`
    open var rightPadding: CGFloat = 8.0 {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    /**
     The height percent of the total available size that the seperator should take up inside the view.
     
     ## Important
     
     This should only be a value between `0.0` and `1.0`. If this value is set past this range, the value
     will be reset to the default value of `0.65`.
     */
    open var seperatorHeightPercent: CGFloat = 0.65 {
        didSet {
            // Clamp the percent between the correct range
            if seperatorHeightPercent < 0.0 || seperatorHeightPercent > 1.0 {
                self.seperatorHeightPercent = 0.95
            }
            self.setNeedsLayout()
        }
    }
    
    /// The width for the seperator, default is `1.5`
    open var seperatorWidth: CGFloat = 1.5 {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    /// The amount of padding from the right side of the seperator (next to the button), default is `20.0`
    open var seperatorPadding: CGFloat = 20.0 {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    /// The default opacity for the view
    internal let defaultOpacity: Float = 0.98
    
    // MARK: Overrides
    
    /// Overriden
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    /// Overriden
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    /// Overriden, lays out the `seperator`
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        // Layout the seperator, want it next to the button and centered vertically
        let seperatorHeight = frame.height * seperatorHeightPercent
        let seperatorY = (frame.height - seperatorHeight) / 2
        seperator.frame = CGRect(x: button.frame.minX - seperatorWidth - seperatorPadding, y: seperatorY,
                                 width: seperatorWidth, height: seperatorHeight)
    }
    
    /// Overriden, posts `snackRemoval` notification.
    open override func removeFromSuperview() {
        super.removeFromSuperview()
        // Will be removed from superview, post notification
        let notification = Notification(name: snackRemoval)
        NotificationCenter.default.post(notification)
    }
    
    // MARK: Private methods
    
    /// Helper initializer which sets some customization for the view and adds the subviews/constraints.
    private func initialize() {
        // Since this self is a container view, set accessibilty element to false
        isAccessibilityElement = false
        // Customize UI
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundColor = UIColor(red: 0.184, green: 0.184, blue: 0.184, alpha: 1.00)
        layer.opacity = defaultOpacity
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 5.0
        layer.shadowOpacity = 0.4
        layer.cornerRadius = 4.0
        
        // Add subviews
        addSubview(titleLabel)
        addSubview(button)
        addSubview(seperator)
        
        //// Add constraints
        // Pin title label to left
        NSLayoutConstraint(item: titleLabel, attribute: .leading, relatedBy: .equal,
                           toItem: self, attribute: .leadingMargin, multiplier: 1.0, constant: leftPadding).isActive = true
        NSLayoutConstraint(item: titleLabel, attribute: .centerY, relatedBy: .equal,
                           toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0).isActive = true
        // Pin button to right
        NSLayoutConstraint(item: button, attribute: .trailing, relatedBy: .equal,
                           toItem: self, attribute: .trailingMargin, multiplier: 1.0, constant: -rightPadding).isActive = true
        NSLayoutConstraint(item: button, attribute: .centerY, relatedBy: .equal,
                           toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0).isActive = true
        
        // Register for device rotation notifications
        NotificationCenter.default.addObserver(self, selector: #selector(self.didRotate(notification:)),
                                               name: .UIDeviceOrientationDidChange, object: nil)
    }
    
    /// Called whenever the screen is rotated, this will ask the controller to recalculate the frame for the view.
    @objc private func didRotate(notification: Notification) {
        // Layout the view/subviews again
        DispatchQueue.main.async {
            // Set frame for self
            self.frame = self.controller?.frameForView() ?? .zero
        }
    }
    
    // MARK: Actions
    
    /// Called whenever the button is tapped, will tell the controller to perform the button action
    @objc private func buttonTapped(sender: UIButton) {
        // Notify controller that button was tapped
        controller?.viewButtonTapped()
    }
    
    // MARK: Subviews
    
    /// The label on the left hand side of the view used to display text.
    open lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.textColor = UIColor.white
        return label
    }()
    
    /// The button on the right hand side of the view which allows an action to be performed.
    open lazy var button: UIButton = {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor(red: 0.702, green: 0.867, blue: 0.969, alpha: 1.00), for: .normal)
        button.addTarget(self, action: #selector(self.buttonTapped(sender:)), for: .touchUpInside)
        return button
    }()
    
    /// A small view which adds an accent that seperates the `titleLabel` and the `button`.
    open lazy var seperator: UIView = {
        let seperator = UIView(frame: .zero)
        seperator.isAccessibilityElement = false
        seperator.backgroundColor = UIColor(red: 0.366, green: 0.364, blue: 0.368, alpha: 1.00)
        seperator.layer.cornerRadius = 2.0
        return seperator
    }()
    
    // MARK: Deinit
    
    /// Deinitializes the view
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

