//
//  CustomBaseButton.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 22/05/21.
//

import UIKit

class CustomBaseButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(cornerRad: CGFloat) {
        self.init(frame:.zero)
        layer.cornerRadius = cornerRad
        layer.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
