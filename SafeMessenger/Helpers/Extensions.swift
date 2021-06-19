//
//  Extensions.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 21/05/21.
//

import Foundation
import UIKit

extension UIView {
    public var width: CGFloat {
        return self.frame.size.width
    }
    
    public var height: CGFloat {
        return self.frame.size.height
    }
    
    public var top: CGFloat {
        return self.frame.origin.y
    }
    
    public var bottom: CGFloat {
        return self.frame.origin.y + height
    }
    
    public var left: CGFloat {
        return self.frame.origin.x
    }
    
    public var right: CGFloat {
        return left + width
    }
}

extension String {
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: self)
    }
    
    func isValidName() -> Bool {
        let regex = try! NSRegularExpression(pattern: "[a-zA-Z\\s]+", options: [])
        let range = regex.rangeOfFirstMatch(in: self, options: [], range: NSRange(location: 0, length: self.count))
        return range.length == self.count
    }
}


extension UIViewController {
    func makeNavigationBarTransperant() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
    }
}

extension Notification.Name {
    static let didLogInNotification =  Notification.Name("didLogInNotification")
}

extension UITableViewCell {
    static var reusableIdentifier: String {
        return String(describing: self)
    }
}

extension DispatchQueue {
    static func background(delay: Double = 0.0, background: (()->Void)? = nil, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .background).async {
            background?()
            if let completion = completion {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                    completion()
                })
            }
        }
    }
}

extension UIColor {
    func image(_ size: CGSize = CGSize(width: 10, height: 10)) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { rendererContext in
            self.setFill()
            rendererContext.fill(CGRect(origin: .zero, size: size))
        }
    }
}
