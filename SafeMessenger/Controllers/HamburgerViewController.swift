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
    
    private lazy var signOutBtn : UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .clear
        btn.setTitle("Sign Out", for: .normal)
        btn.setTitleColor(.label, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        btn.addTarget(self, action: #selector(signOutTapped), for: .touchUpInside)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.alpha = 0.99
        view.backgroundColor = UIColor(patternImage: viewModel.hamburgerBackground)
        
        view.addSubview(imageView)
        view.addSubview(signOutBtn)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let imageViewSize = view.width / 3
        imageView.layer.cornerRadius = imageViewSize / 2
        imageView.frame = CGRect(x: (view.width - imageViewSize) / 2,
                                 y: view.height / 15,
                                 width: imageViewSize,
                                 height: imageViewSize)
        signOutBtn.frame = CGRect(x: (view.width - 100)/2 ,
                                  y: view.height - 80,
                                  width: 100,
                                  height: 40)
    }
}

extension HamburgerViewController {
    @objc private func signOutTapped() {
        viewModel.handleSignOutTapped { success in
            if success {
                print("HamburgerViewController: Sign out successful")
                let vc = self.storyboard?.instantiateViewController(identifier: "chatMultiViewControllerSt")
                vc?.modalPresentationStyle = .fullScreen
                self.present(vc!, animated: true, completion: nil)
            }
            else {
                print("HamburgerViewController: Sign out failed")
            }
        }
    }
}
