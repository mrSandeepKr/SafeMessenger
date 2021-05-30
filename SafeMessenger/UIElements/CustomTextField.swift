//
//  CustomTextField.swift
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

protocol UnderlinedTextFieldDelegate: AnyObject {
    func underlineTextFieldShouldReturn(_ sender: UnderlinedTextField) -> Bool
}

class UnderlinedTextField: UIView, UITextFieldDelegate {
    private var lineThick: CGFloat!
    private var lineColor: UIColor!
    
    public weak var delegate: UnderlinedTextFieldDelegate?
    public var text:String? {
        return textField.text
    }
    private lazy var textField: UITextField = {
        let textField = UITextField()
    
        return textField
    }()
    
    private lazy var lineView: LineView = {
        let line = LineView(lineColor: lineColor)
        return line
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(lineThickness: CGFloat,
                     placeholder: String,
                     lineColor: UIColor,
                     returnKeyType: UIReturnKeyType = .default,
                     isPassword: Bool = false) {
        self.init(frame:.zero)
        lineThick = lineThickness
        self.lineColor = lineColor
        
        addSubview(textField)
        addSubview(lineView)
        textField.placeholder = placeholder
        textField.returnKeyType = returnKeyType
        textField.isSecureTextEntry = isPassword
        textField.delegate = self
        textField.textContentType = .oneTimeCode
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textField.frame = CGRect(x: 0, y: 0, width: width, height: height - lineThick)
        lineView.frame = CGRect(x: 0, y: textField.bottom, width: width, height: lineThick)
    }
    
    override func becomeFirstResponder() -> Bool {
        return textField.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let delegate = delegate {
            return delegate.underlineTextFieldShouldReturn(self)
        }
        return true
    }
}
