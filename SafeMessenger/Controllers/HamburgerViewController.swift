//
//  HamburgerViewController.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 29/05/21.
//

import UIKit

class HamburgerViewController: UIViewController {
    private var viewModel = HamburgerViewModel()
    
    private lazy var imageView : UIImageView = {
        let imageView = UIImageView(image: viewModel.profileImage)
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(imageView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let imageViewSize = view.width / 3
        imageView.layer.cornerRadius = imageViewSize / 2
        imageView.frame = CGRect(x: (view.width - imageViewSize) / 2,
                                 y: view.height / 15,
                                 width: imageViewSize,
                                 height: imageViewSize)
    }
}
