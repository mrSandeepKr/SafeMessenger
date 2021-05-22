//
//  CustomEntryTextField.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 21/05/21.
//

import UIKit

class RounderCornerTextField: UITextField {
    private func setupTextField() {
        self.autocapitalizationType = .none
        self.autocorrectionType = .no
        self.returnKeyType = .continue
        self.layer.cornerRadius = 12
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.masksToBounds = true
        self.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        self.leftViewMode = .always
    }

    init(placeholder:String? = "",isPassword: Bool = false) {
        super.init(frame:.zero)
        setupTextField()
        self.placeholder = placeholder
        self.isSecureTextEntry = isPassword
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
