//
//  LPSnackbar.swift
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

/**
 The controller for an `LPSnackbarView`.
 
 This class handles everything that has to do with showing, dismissing and performing actions in a `LPSnackbarView`.
 There are several static helper methods, which allow presenting a basic snack without needing instantiate an `LPSnackbar` yourself.
 */
open class LPSnackbar: Equatable {
    
    // MARK: Public Members
    
    /// The `LPSnackbarView` for the controller, access this view and it's subviews to do any additional customization.
    open lazy var view: LPSnackbarView = {
        let snackView = LPSnackbarView(frame: .zero)
        snackView.controller = self
        snackView.isHidden = true
        return snackView
    }()
    
    /**
     The width percent of the total available size that the `view` should take up.
     
     ## Important
     
     This should only be a value between `0.0` and `1.0`. If this value is set past this range, the value
     will be reset to the default value of `0.98`.
     */
    open var widthPercent: CGFloat = 0.98 {
        didSet {
            // Clamp at between the range
            if self.widthPercent < 0.0 || self.widthPercent > 1.0 {
                self.widthPercent = 0.98
            }
            self.view.setNeedsLayout()
        }
    }
    
    /**
     The height for the `LPSnackbarView`.
     
     ## Important
     
     Do not set the frame of the `view` yourself. Instead set the `widthPercent` and `height`.
     Setting the frame for `view` can have unexpected results as the frame is calculated in a different way depending
     on many variables.
     */
    open var height: CGFloat = 40.0 {
        didSet {
            // Update height
            self.view.setNeedsLayout()
        }
    }
    
    /**
     The bottom spacing for the `view`.
     
     For example, by default the `view` is placed in the main `UIWindow` of an application with a default
     bottom spacing of `12.0`, however, if you have a `UITabBarController` you may want to increase the bottom spacing
     so that the snack is presented above the bar.
     */
    open var bottomSpacing: CGFloat = 12.0 {
        didSet {
            // Update frame
            self.view.setNeedsLayout()
        }
    }
    
    /// Similar to the `bottomSpacing` property, except this is only used when multiple `LPSnackbarViews` are stacked.
    open var stackedBottomSpacing: CGFloat = 8.0 {
        didSet {
            // Update any layouts
            self.view.setNeedsLayout()
        }
    }
    
    /// Optional view to display the `view` in, by default this is `nil`, thus the main `UIWindow` is used for presentation.
    open var viewToDisplayIn: UIView?
    
    /// The duration for the animation of both the adding and removal of the `view`.
    open var animationDuration: TimeInterval = 0.5
    
    /// The completion block for an `LPSnackbar`, `true` is sent if button was tapped, `false` otherwise.
    public typealias SnackbarCompletion = (Bool) -> Void
    
    // MARK: Private Members
    
    /// The timer responsible for notifying about when the view needs to be removed.
    private var displayTimer: Timer?
    
    /// How long the view will be presented for.
    private var displayDuration: TimeInterval?
    
    /// Whether or not the view was initially animated, this is used when animating out the view.
    private var wasAnimated: Bool = false
    
    /// The completion block which is assigned when calling `show(animated:completion:)`
    private var completion: SnackbarCompletion?
    
    // MARK: Initializers
    
    /**
     Creates an `LPSnackbar`.
     
     ## Important
     
     If `buttonTitle` is `nil`, no button will be displayed.
     
     If `displayDuration` is `nil`, the view will not be removed unless swiped away or button is pressed.
     */
    public init (title: String, buttonTitle: String?, displayDuration: TimeInterval? = 5.0) {
        self.displayDuration = displayDuration
        
        // Set labels/buttons
        view.titleLabel.text = title
        
        if let bTitle = buttonTitle {
            view.button.setTitle(bTitle, for: .normal)
        } else {
            // Remove button
            view.button.removeFromSuperview()
        }
        
        // Finish initialization
        finishInit()
    }
    
    /**
     Creates an `LPSnackbar`.
     
     ## Important
     
     If `attributedButtonTitle` is `nil`, no button will be displayed.
     
     If `displayDuration` is `nil`, the view will not be removed unless swiped away or button is pressed.
     */
    public init(attributedTitle: NSAttributedString, attributedButtonTitle: NSAttributedString?, displayDuration: TimeInterval? = 5.0) {
        self.displayDuration = displayDuration
        
        // Set labels/buttons
        view.titleLabel.attributedText = attributedTitle
        
        if let bTitle = attributedButtonTitle {
            view.button.setAttributedTitle(bTitle, for: .normal)
        } else {
            // Remove button
            view.button.removeFromSuperview()
        }
        
        // Finish initialization
        finishInit()
    }
    
    /// Helper method which creates the timer (if needed) and adds the swipe gestures to the view
    private func finishInit() {
        // Set timer for when view will be removed
        if let duration = displayDuration {
            displayTimer = Timer.scheduledTimer(timeInterval: duration,
                                                target: self,
                                                selector: #selector(self.timerDidFinish),
                                                userInfo: nil,
                                                repeats: false)
        }
        
        // Add gesture recognizers for swipes
        let left = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipes(sender:)))
        left.direction = .left
        let right = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipes(sender:)))
        right.direction = .right
        let down = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipes(sender:)))
        down.direction = .down
        view.addGestureRecognizer(left)
        view.addGestureRecognizer(right)
        view.addGestureRecognizer(down)
        
        // Register for snack removal notifications
        NotificationCenter.default.addObserver(self, selector: #selector(self.snackWasRemoved(notification:)),
                                               name: snackRemoval, object: nil)
    }
    
    
    // MARK: Helper Methods
    
    /// Returns the calculated/appropriate frame for the view, takes into account whether there are multiple snacks on the view.
    internal func frameForView() -> CGRect {
        guard let superview = viewToDisplayIn ?? UIApplication.shared.keyWindow ?? nil else {
            return .zero
        }
        
        // Set frame for view
        let width: CGFloat = superview.bounds.width * widthPercent
        let startX: CGFloat = (superview.bounds.width - width) / 2.0
        
        let startY: CGFloat
        
        // Check to see if a snackbar is already being presented in this view
        var snackView: LPSnackbarView?
        for sub in superview.subviews {
            // Loop until we find the last snack view, since it should be the last one displayed in the superview
            // and the snack view should be below the current snack view
            if let snack = sub as? LPSnackbarView, snack !== view, snack.frame.maxY > view.frame.maxY {
                snackView = snack
            }
        }
        
        if let snack = snackView {
            startY = snack.frame.maxY - snack.frame.height - height - stackedBottomSpacing
        } else {
            startY = superview.bounds.maxY - height - bottomSpacing
        }
        
        return CGRect(x: startX, y: startY, width: width, height: height)
    }
    
    /// Prepares the `LPSnackbar` for removal
    private func prepareForRemoval() {
        NotificationCenter.default.removeObserver(self)
        view.controller = nil
        view.removeFromSuperview()
    }
    
    // MARK: Animation
    
    /// Animates the view in using a springy/bounce effect
    private func animateIn() {
        let frame = frameForView()
        let inY = frame.origin.y
        let outY = frame.origin.y + height + bottomSpacing
        // Set up view outside the frame, then animate it back in
        view.isHidden = false
        let oldOpacity = view.layer.opacity
        view.layer.opacity = 0.0
        view.frame = CGRect(x: frame.origin.x, y: outY, width: frame.width, height: frame.height)
        
        UIView.animate(
            withDuration: animationDuration,
            delay: 0.1,
            usingSpringWithDamping: 0.4,
            initialSpringVelocity: 0.0,
            options: .curveEaseInOut,
            animations: {
                // Animate the view to the correct position & opacity
                self.view.layer.opacity = oldOpacity
                self.view.frame = CGRect(x: frame.origin.x, y: inY, width: frame.width, height: frame.height)
        },
            completion: nil
        )
        
        wasAnimated = true
    }
    
    /// Animates the view in by moving down towards the edge of the screen and fading it out
    private func animateOut(wasButtonTapped: Bool = false) {
        let frame = view.frame
        let outY = frame.origin.y + height + bottomSpacing
        let pos = CGPoint(x: frame.origin.x, y: outY)
        
        UIView.animate(
            withDuration: animationDuration,
            animations: {
                self.view.frame = CGRect(origin: pos, size: frame.size)
                self.view.layer.opacity = 0.0
        },
            completion: { _ in
                // Call the completion handler
                self.completion?(wasButtonTapped)
                // Prepare to deinit
                self.prepareForRemoval()
        }
        )
    }
    
    /// Animates the swipe of a view by moving it to a specified position
    private func animateSwipeOut(to position: CGPoint) {
        // Invalidate timer
        displayTimer?.invalidate()
        displayTimer = nil
        
        UIView.animate(
            withDuration: animationDuration,
            delay: 0.0,
            options: .curveEaseOut,
            animations: {
                // Animate to postion
                self.view.frame = CGRect(origin: position, size: self.view.frame.size)
                self.view.layer.opacity = 0.1
        }, completion: { _ in
            self.completion?(false)
            self.prepareForRemoval()
        }
        )
    }
    
    // MARK: Actions
    
    /// Called whenever the `displayTimer` is done, will animate the view out if allowed
    @objc private func timerDidFinish() {
        if wasAnimated {
            self.animateOut()
        } else {
            // Call the completion handler, since no animation will be shown
            completion?(false)
            // Prepare to deinit
            prepareForRemoval()
        }
    }
    
    /// Called whenever the `views`'s button is tapped, will animate the view out if allowed
    internal func viewButtonTapped() {
        // If timer is active, invalidate since view will now dissapear no matter what
        displayTimer?.invalidate()
        displayTimer = nil
        
        if wasAnimated {
            // Animate the view out, which will in turn call the completion handler
            self.animateOut(wasButtonTapped: true)
        } else {
            // Call the completion handler, since no animation will be shown
            completion?(true)
            // Prepare to deinit
            prepareForRemoval()
        }
    }
    
    /// Called when another `LPSnackbarView` was removed from the screen. Refreshes the frame of the current `LPSnackbarView`.
    @objc private func snackWasRemoved(notification: Notification) {
        // Recalculate the frame, since another snack view has been removed
        // If this view was on top, it will look weird to have it floating in the same place
        UIView.animate(
            withDuration: 0.2,
            delay: 0.0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 0.0,
            options: .curveEaseOut,
            animations: {
                // Update the frame
                self.view.frame = self.frameForView()
        }, completion: nil)
    }
    
    /// Handles left, right, and bottom swipes on the view by animating them out
    @objc private func handleSwipes(sender: UISwipeGestureRecognizer) {
        switch sender.direction {
        case .left:
            let position = CGPoint(x: view.frame.origin.x - view.frame.width, y: view.frame.origin.y)
            animateSwipeOut(to: position)
        case .right:
            let position = CGPoint(x: view.frame.origin.x + view.frame.width, y: view.frame.origin.y)
            animateSwipeOut(to: position)
        case .down:
            let position = CGPoint(x: view.frame.origin.x, y: view.frame.origin.y + view.frame.height + bottomSpacing)
            animateSwipeOut(to: position)
        case .up: fallthrough
        default: break
        }
    }
    
    // MARK: Public Methods
    
    /// Presents the snack to the screen
    open func show(animated: Bool = true, completion: SnackbarCompletion? = nil) {
        guard let superview = viewToDisplayIn ?? UIApplication.shared.keyWindow ?? nil else {
            print("Unable to get a superview, was not able to show\n Couldn't add LPSnackbarView as a subview to the main UIWindow")
            return
        }
        
        // Add as subview
        superview.addSubview(self.view)
        
        // Set completion and animate the view if allowed
        self.completion = completion
        
        if animated {
            animateIn()
        } else {
            view.isHidden = false
        }
    }
    
    /**
     Allows you to manually dismiss the snack from the screen.

     - `animated`: Whether or not to animate the view out.
     
     - `completeWithAction`: Whether or not if when dismissing, you want to pass true to the `SnackbarCompletion`, which
                             means that it will act as if the button was pressed by the user.
     */
    open func dismiss(animated: Bool = true, completeWithAction: Bool = false) {
        guard !completeWithAction else {
            self.viewButtonTapped()
            return
        }
        
        if animated {
            self.animateOut()
        } else {
            prepareForRemoval()
        }
    }
    
    // MARK: Static Methods
    
    /// Allows showing a simple snack without needing to instantiate any `LPSnackbar`
    open static func showSnack(title: String, displayDuration: TimeInterval? = 5.0, completion: SnackbarCompletion? = nil) {
        let snack = LPSnackbar(title: title, buttonTitle: nil, displayDuration: displayDuration)
        snack.show(animated: true) { _ in
            completion?(false)
        }
    }
    
    /// Allows showing a simple, more customizable, snack without needing to instantiate any `LPSnackbar`
    open static func showSnack(attributedTitle: NSAttributedString, displayDuration: TimeInterval? = 5.0, completion: SnackbarCompletion? = nil) {
        let snack = LPSnackbar(attributedTitle: attributedTitle, attributedButtonTitle: nil, displayDuration: displayDuration)
        snack.show(animated: true) { _ in
            completion?(false)
        }
    }
    
    // MARK: Equatable
    
    /// Returns equals if and only if `lhs` and `rhs` are the same object.
    open static func ==(lhs: LPSnackbar, rhs: LPSnackbar) -> Bool {
        return lhs === rhs
    }
}
