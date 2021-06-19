//
//  SearchResultTableViewCell.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 17/06/21.
//

import Foundation
import UIKit

class SearchResultTableViewCell: UITableViewCell {
    private let contentHeight: CGFloat = 60
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11, weight: .thin)
        label.numberOfLines = 1
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var cellIcon: UIImageView = {
        let image = UIImage(named: Constants.ImageNameMemberPlaceholder)
        let imageView = UIImageView(image: image)
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderWidth = 0.5
        imageView.layer.borderColor = UIColor.label.cgColor
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private var constraintsNotActive = false
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(cellIcon)
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate(staticConstraints())
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func staticConstraints() -> [NSLayoutConstraint] {
        var constraints = [NSLayoutConstraint]()

        let imageSide = 0.15 * contentHeight
        let imageSize = contentHeight - (2 * imageSide)
        cellIcon.layer.cornerRadius = imageSize / 2.0
        
        let titleHeight = 0.40 * contentHeight
        let subtitleHeight = 0.30 * contentHeight
        
        constraints.append(contentsOf: [
            cellIcon.topAnchor.constraint(equalTo: topAnchor, constant: imageSide),
            cellIcon.leadingAnchor.constraint(equalTo: leadingAnchor, constant: imageSide),
            cellIcon.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1 * imageSide),
            cellIcon.widthAnchor.constraint(equalToConstant: imageSize)
        ])
        
        constraints.append(contentsOf: [
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: imageSide),
            titleLabel.leadingAnchor.constraint(equalTo: cellIcon.trailingAnchor, constant: imageSide),
            titleLabel.heightAnchor.constraint(equalToConstant: titleHeight),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -1 * imageSide)
        ])
       
        constraints.append(contentsOf: [
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            subtitleLabel.leadingAnchor.constraint(equalTo: cellIcon.trailingAnchor, constant: imageSide),
            subtitleLabel.heightAnchor.constraint(equalToConstant: subtitleHeight),
            subtitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -1 * imageSide)
        ])
        
        return constraints
    }
}

extension SearchResultTableViewCell {
    func configureCell(with model:ChatAppUserModel) {
        titleLabel.text = model.displayName
        subtitleLabel.text = model.email
        cellIcon.sd_setImage(with: model.imageURL)
    }
}
