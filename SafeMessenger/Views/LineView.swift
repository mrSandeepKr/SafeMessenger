//
//  LineView.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 22/05/21.
//

import UIKit

class LineView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(lineColor: UIColor) {
        self.init(frame: .zero)
        backgroundColor = lineColor
        layer.borderColor = lineColor.cgColor
    }
}
