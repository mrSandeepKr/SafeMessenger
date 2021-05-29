//
//  ChatListMultiViewController.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 29/05/21.
//

import UIKit

class ChatListMultiViewController: UIViewController {
    
    private let viewModel = ChatListMultiViewModel()
    private lazy var hamburgerHeight = (self.navigationController?.navigationBar.frame.height ?? 0) * 0.9
    @IBOutlet weak var hamburgerSuperView: UIView!
    @IBOutlet weak var hamburgerWidth: NSLayoutConstraint!
    @IBOutlet weak var hamburgerViewBackground: UIView!
    @IBOutlet weak var hamburgerLeadingConstraint: NSLayoutConstraint!
    
    private lazy var chatListViewController : ChatListViewController = {
        let viewController = ChatListViewController()
        viewController.view.backgroundColor = .black
        return viewController
    }()
    
    private lazy var hamburgerBtn: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "personPlaceholder")
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = hamburgerHeight / 2
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.label.cgColor
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showHamburgerView)))
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        basicSetUp()
        
        view.addSubview(hamburgerBtn)
        view.addSubview(chatListViewController.view)
        view.bringSubviewToFront(hamburgerSuperView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let safeAreaTop = view.safeAreaInsets.top
        hamburgerBtn.frame = CGRect(x: 10,
                                    y: safeAreaTop,
                                    width: hamburgerHeight,
                                    height: hamburgerHeight)
        chatListViewController.view.frame = CGRect(x: 0,
                                                   y: safeAreaTop + hamburgerHeight + 5,
                                                   width: view.width,
                                                   height: view.height - safeAreaTop)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        guard viewModel.isLoggedIn else{
            presetLoginScreen()
            return
        }
    }
    
    private func basicSetUp() {
        navigationController?.navigationBar.isHidden = true
        hamburgerSuperView.backgroundColor = .clear
        hideHamburgerView()
    }
    
    private func hideHamburgerView() {
        hamburgerSuperView.isHidden = true
        hamburgerLeadingConstraint.constant = -1.0 * hamburgerWidth.constant
    }
    
    @objc func showHamburgerView() {
        hamburgerSuperView.isHidden = false
        hamburgerLeadingConstraint.constant = 0
    }
}

extension ChatListMultiViewController {
    private func presetLoginScreen() {
        let vc = LogInViewController()
        let nav = UINavigationController(rootViewController: vc)
        nav.navigationBar.prefersLargeTitles = true
        nav.viewControllers.first?.navigationItem.largeTitleDisplayMode = .always
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true)
    }
}

