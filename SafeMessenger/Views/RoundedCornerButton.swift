//
//  RoundedCornerButton.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 22/05/21.
//

import UIKit

class RoundedCornerButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(cornerRad: CGFloat, btnTitle: String, btnColor: UIColor, borderColor: UIColor) {
        self.init(frame: .zero)
        
        setTitle(btnTitle, for: .normal)
        titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        backgroundColor = btnColor
        
        layer.cornerRadius = cornerRad
        layer.masksToBounds = true
        layer.borderColor = borderColor.cgColor
        layer.borderWidth = 1
    }
}
