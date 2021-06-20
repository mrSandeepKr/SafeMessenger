//
//  SubtitleTableViewCell.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 20/06/21.
//

import Foundation
import UIKit

class SubtitleTableViewCell: UITableViewCell {
    private lazy var title: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var subTitle: UILabel = {
        let label = UILabel()
        label.numberOfLines = 3
        label.textColor = .secondaryLabel
        label.lineBreakMode = .byWordWrapping
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .justified
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(title)
        addSubview(subTitle)
        NSLayoutConstraint.activate(getStaticConstraints())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func getStaticConstraints() -> [NSLayoutConstraint] {
        var constraints: [NSLayoutConstraint] = []
        constraints.append(contentsOf: [
            title.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            title.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            title.heightAnchor.constraint(equalToConstant: 20),
            title.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        constraints.append(contentsOf: [
            subTitle.topAnchor.constraint(equalTo: title.bottomAnchor, constant:  10),
            subTitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            subTitle.bottomAnchor.constraint(equalTo: bottomAnchor),
            subTitle.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14)
        ])
        
        return constraints
    }
    
    func configureCell(titleText: String, subTitleText: String) {
        title.text = titleText
        subTitle.text = subTitleText
    }
}
