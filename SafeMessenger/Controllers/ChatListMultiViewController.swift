//
//  ChatListMultiViewController.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 29/05/21.
//

import UIKit

class ChatListMultiViewController: UIViewController {
    // View Model for ChatList MultiViewController
    private let viewModel = ChatListMultiViewModel()
    
    //Hamburger Support
    private lazy var hamburgerHeight = (self.navigationController?.navigationBar.frame.height ?? 0) * 0.9
    private var isHamburgerOnScreen: Bool = false
    private var touchesBeginPoint: CGFloat = 0.0
    
    // Elements
    @IBOutlet weak var hamburgerSuperView: UIView!
    @IBOutlet weak var hamburgerWidth: NSLayoutConstraint!
    @IBOutlet weak var hamburgerViewBackground: UIView!
    @IBOutlet weak var hamburgerLeadingConstraint: NSLayoutConstraint!
    
    private lazy var chatListViewController : ChatListViewController = {
        let viewController = ChatListViewController()
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
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hamburgerBtnTapped)))
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        basicSetUp()
        
        view.addSubview(hamburgerBtn)
        view.addSubview(chatListViewController.view)
        view.bringSubviewToFront(hamburgerSuperView)
        view.bringSubviewToFront(hamburgerViewBackground)
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
        hamburgerSuperView.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                       action: #selector(singleTapHamburgerBackground)))
    }
    
    @objc private func hamburgerBtnTapped() {
        showHamburgerViewWithAnimation()
    }
    
    @objc private func singleTapHamburgerBackground() {
        hideHamburgerViewWithAnimation()
    }
}

//MARK: Login & Hamburger Helpers
extension ChatListMultiViewController {
    private func presetLoginScreen() {
        let vc = LogInViewController()
        let nav = UINavigationController(rootViewController: vc)
        nav.navigationBar.prefersLargeTitles = true
        nav.viewControllers.first?.navigationItem.largeTitleDisplayMode = .always
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true)
    }
    
    // Hamburger View Helper Methods
    private func hideHamburgerViewWithAnimation() {
        UIView.animate(
            withDuration: 0.2,
            animations: { [weak self] in
                self?.hamburgerLeadingConstraint.constant = 10
                self?.view.layoutIfNeeded()
            }) { _ in
            UIView.animate(
                withDuration: 0.1,
                animations: { [weak self] in
                    self?.hamburgerLeadingConstraint.constant = -1.0 * (self?.hamburgerWidth.constant)!
                    self?.view.layoutIfNeeded()
                }) { [weak self] _ in
                self?.hamburgerSuperView.isHidden = true
                self?.isHamburgerOnScreen = false
            }
        }
    }
    
    private func showHamburgerViewWithAnimation() {
        UIView.animate(
            withDuration: 0.1,
            animations: { [weak self] in
                self?.hamburgerLeadingConstraint.constant = 10
                self?.view.layoutIfNeeded()
            }) { _ in
            UIView.animate(
                withDuration: 0.2,
                animations: { [weak self] in
                    self?.hamburgerLeadingConstraint.constant = 0
                    self?.view.layoutIfNeeded()
                }) { [weak self] _ in
                self?.hamburgerSuperView.isHidden = false
                self?.isHamburgerOnScreen = true
            }
        }
    }
    
    // Hamburger movement code
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isHamburgerOnScreen {
            if let touch = touches.first {
                let location = touch.location(in: hamburgerSuperView)
                touchesBeginPoint = location.x
                
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isHamburgerOnScreen {
            
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isHamburgerOnScreen {
            
        }
    }
}

