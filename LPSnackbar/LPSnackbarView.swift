//
//  LPSnackbarView.swift
//  LPSnackbar
//
//  Created by Luis Padron on 7/11/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit

internal let snackRemoval: Notification.Name = Notification.Name(rawValue: "com.luispadron.LPSnackbar.removalNotification")

open class LPSnackbarView: UIView {
    
    // MARK: Properties
    
    internal var controller: LPSnackbar?
    
    open var leftPadding: CGFloat = 8.0 {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    open var rightPadding: CGFloat = 8.0 {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    open var seperatorHeightPercent: CGFloat = 0.65 {
        didSet {
            // Clamp the percent between the correct range
            if seperatorHeightPercent < 0.0 || seperatorHeightPercent > 1.0 {
                self.seperatorHeightPercent = 0.95
            }
            self.setNeedsLayout()
        }
    }
    
    open var seperatorWidth: CGFloat = 1.5 {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    open var seperatorPadding: CGFloat = 20.0 {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    // MARK: Overrides
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        // Layout the seperator, want it next to the button and centered vertically
        let seperatorHeight = frame.height * seperatorHeightPercent
        let seperatorY = (frame.height - seperatorHeight) / 2
        seperator.frame = CGRect(x: button.frame.minX - seperatorWidth - seperatorPadding, y: seperatorY,
                                 width: seperatorWidth, height: seperatorHeight)
    }
    
    open override func removeFromSuperview() {
        super.removeFromSuperview()
        // Will be removed from superview, post notification
        let notification = Notification(name: snackRemoval)
        NotificationCenter.default.post(notification)
    }
    
    // MARK: Private methods
    
    private func initialize() {
        // Customize UI
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundColor = UIColor(red: 0.184, green: 0.184, blue: 0.184, alpha: 1.00)
        layer.opacity = 0.98
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
    
    @objc private func didRotate(notification: Notification) {
        // Layout the view/subviews again
        DispatchQueue.main.async {
            // Set frame for self
            self.frame = self.controller?.frameForView() ?? .zero
        }
    }
    
    // MARK: Actions
    
    @objc private func buttonTapped(sender: UIButton) {
        // Notify controller that button was tapped
        controller?.viewButtonTapped()
    }
    
    // MARK: Subviews
    
    open lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.textColor = UIColor.white
        return label
    }()
    
    open lazy var button: UIButton = {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor(red: 0.702, green: 0.867, blue: 0.969, alpha: 1.00), for: .normal)
        button.addTarget(self, action: #selector(self.buttonTapped(sender:)), for: .touchUpInside)
        return button
    }()
    
    open lazy var seperator: UIView = {
        let seperator = UIView(frame: .zero)
        seperator.backgroundColor = UIColor(red: 0.366, green: 0.364, blue: 0.368, alpha: 1.00)
        seperator.layer.cornerRadius = 2.0
        return seperator
    }()
    
    // MARK: Deinit
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

