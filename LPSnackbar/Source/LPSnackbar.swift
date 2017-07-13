//
//  LPSnackbar.swift
//  LPSnackbar
//
//  Created by Luis Padron on 7/11/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit

open class LPSnackbar {
    
    // MARK: Public Members
    
    open lazy var view: LPSnackbarView = {
        let snackView = LPSnackbarView(frame: .zero)
        snackView.controller = self
        snackView.isHidden = true
        return snackView
    }()
    
    open var widthPercent: CGFloat = 0.98 {
        didSet {
            // Clamp at between the range
            if self.widthPercent < 0.0 || self.widthPercent > 1.0 {
                self.widthPercent = 0.98
            }
            self.view.setNeedsLayout()
        }
    }
    
    open var height: CGFloat = 40.0 {
        didSet {
            // Update height
            self.view.setNeedsLayout()
        }
    }
    
    open var bottomSpacing: CGFloat = 12.0 {
        didSet {
            // Update frame
            self.view.setNeedsLayout()
        }
    }
    
    open var bottomSpacingWhenStacked: CGFloat = 8.0 {
        didSet {
            // Update any layouts
            self.view.setNeedsLayout()
        }
    }
    
    open var viewToDisplayIn: UIView?
    
    open var animationDuration: TimeInterval = 0.5
    
    public typealias SnackbarCompletion = (Bool) -> Void
    
    // MARK: Private Members
    
    private var displayTimer: Timer?
    private var displayDuration: TimeInterval?
    
    private var wasAnimated: Bool = false
    
    private var completion: SnackbarCompletion?
    
    // MARK: Initializers
    
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
            startY = snack.frame.maxY - snack.frame.height - height - bottomSpacingWhenStacked
        } else {
            startY = superview.bounds.maxY - height - bottomSpacing
        }
        
        return CGRect(x: startX, y: startY, width: width, height: height)
    }
    
    private func prepareForRemoval() {
        NotificationCenter.default.removeObserver(self)
        view.controller = nil
        view.removeFromSuperview()
    }
    
    // MARK: Animation
    
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
    
    open func dismiss(animated: Bool = true) {
        if animated {
            self.animateOut()
        } else {
            prepareForRemoval()
        }
    }
    
    // MARK: Static Methods
    
    open static func showSnack(title: String, displayDuration: TimeInterval? = 5.0, completion: SnackbarCompletion? = nil) {
        let snack = LPSnackbar(title: title, buttonTitle: nil, displayDuration: displayDuration)
        snack.show(animated: true) { _ in
            completion?(false)
        }
    }
    
    open static func showSnack(attributedTitle: NSAttributedString, displayDuration: TimeInterval? = 5.0, completion: SnackbarCompletion? = nil) {
        let snack = LPSnackbar(attributedTitle: attributedTitle, attributedButtonTitle: nil, displayDuration: displayDuration)
        snack.show(animated: true) { _ in
            completion?(false)
        }
    }
}

