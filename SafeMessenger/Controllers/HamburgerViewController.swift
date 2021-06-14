//
//  HamburgerViewController.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 29/05/21.
//

import UIKit

class HamburgerViewController: UIViewController {
    private var viewModel = HamburgerViewModel()
    private var logInObserver: NSObjectProtocol?
    
    private lazy var profileImageView : UIImageView = {
        let image = UIImage(named: viewModel.profileImageName!)
        let imageView = UIImageView(image: image)
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
        view.backgroundColor = UIColor(patternImage: UIImage(named: viewModel.hamburgerBackgroundImageName!)!)
        
        logInObserver = NotificationCenter.default.addObserver(forName: .didLogInNotification,
                                                               object: nil,
                                                               queue: .main,
                                                               using: { [weak self] _ in
                                                                guard let strongSelf = self else {
                                                                    return
                                                                }
                                                                strongSelf.viewModel.updateProfileImageView(for: strongSelf.profileImageView)
                                                               })
        
        viewModel.updateProfileImageView(for: profileImageView)
        view.addSubview(profileImageView)
        view.addSubview(signOutBtn)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let imageViewSize = view.width / 3
        profileImageView.layer.cornerRadius = imageViewSize / 2
        profileImageView.frame = CGRect(x: (view.width - imageViewSize) / 2,
                                        y: view.height / 15,
                                        width: imageViewSize,
                                        height: imageViewSize)
        signOutBtn.frame = CGRect(x: (view.width - 100)/2 ,
                                  y: view.height - 80,
                                  width: 100,
                                  height: 40)
    }
    
    deinit {
        if let observer = logInObserver {
            NotificationCenter.default.removeObserver(observer)
        }
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
