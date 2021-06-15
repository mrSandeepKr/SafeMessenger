//
//  ImageViewerViewController.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 21/05/21.
//

import UIKit

class ImageViewerViewController: UIViewController {
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private let url: URL
    private let viewTitle: String
    
    init(url: URL, title: String) {
        self.url = url
        self.viewTitle = title
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = viewTitle
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                                                  style: .done,
                                                                                  target: self,
                                                                                  action: #selector(dismissImageView))
        
        imageView.sd_setImage(with: url, completed: nil)
        view.addSubview(imageView)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageView.frame = view.bounds
    }
    
    @objc func dismissImageView() {
        dismiss(animated: true, completion: nil)
    }
}
