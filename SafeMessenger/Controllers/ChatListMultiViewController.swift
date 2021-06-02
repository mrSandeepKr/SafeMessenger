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
        let viewController = ChatListViewController(viewModel: ChatListViewModel())
        viewController.delegate = self
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
    
    private lazy var appTitle: UILabel = {
        let label = UILabel()
        label.text = "Safe Messenger"
        label.font = .systemFont(ofSize: 30, weight: .bold)
        label.textColor = .label
        return label
    }()
    
    private lazy var newChatButton: UIImageView = {
        let imgBtn = UIImageView(image: UIImage(systemName: "square.and.pencil"))
        imgBtn.contentMode = .scaleAspectFill
        imgBtn.isUserInteractionEnabled = true
        imgBtn.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                           action: #selector(newChatButtonTapped)))
        return imgBtn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        basicSetUp()
        
        view.addSubview(hamburgerBtn)
        view.addSubview(chatListViewController.view)
        view.addSubview(appTitle)
        view.addSubview(newChatButton)
        view.bringSubviewToFront(hamburgerSuperView)
        view.bringSubviewToFront(hamburgerViewBackground)
    }
    
    override func viewDidLayoutSubviews() {
        appTitle.sizeToFit()
        super.viewDidLayoutSubviews()
        let safeAreaTop = view.safeAreaInsets.top
        hamburgerBtn.frame = CGRect(x: 10,
                                    y: safeAreaTop,
                                    width: hamburgerHeight,
                                    height: hamburgerHeight)
        appTitle.frame = CGRect(x: hamburgerBtn.right + 30,
                                y: safeAreaTop,
                                width: appTitle.width,
                                height: hamburgerHeight)
        
        let newChatButtonSize = hamburgerHeight - 13
        newChatButton.frame = CGRect(x: view.right - 15 - newChatButtonSize,
                                     y: safeAreaTop + ((hamburgerHeight - newChatButtonSize) / 2.0),
                                     width: newChatButtonSize,
                                     height: newChatButtonSize)
        chatListViewController.view.frame = CGRect(x: 0,
                                                   y: safeAreaTop + hamburgerHeight + 40,
                                                   width: view.width,
                                                   height: view.height - safeAreaTop)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        view.layoutIfNeeded()
        hideViewsIfNotLoggedIn()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        guard viewModel.isLoggedIn else{
            presetLoginScreen()
            return
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    private func basicSetUp() {
        hideViewsIfNotLoggedIn()
        navigationController?.navigationBar.isHidden = true
        hamburgerWidth.constant = view.width * 0.75
        hamburgerLeadingConstraint.constant = -1 * hamburgerWidth.constant
        hamburgerSuperView.isHidden = true
        hamburgerSuperView.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                       action: #selector(singleTapHamburgerBackground)))
    }
    
    @objc private func hamburgerBtnTapped() {
        showHamburgerViewWithAnimation()
    }
    
    @objc private func singleTapHamburgerBackground() {
        hideHamburgerViewWithAnimation()
    }
    
    @objc private func newChatButtonTapped() {
        let vc = NewChatViewController()
        vc.view.backgroundColor = .green
        navigationController?.present(vc, animated: true)
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
    
    private func hideViewsIfNotLoggedIn() {
        let isHidden = !viewModel.isLoggedIn
        hamburgerBtn.isHidden = isHidden
        chatListViewController.view.isHidden = isHidden
    }
    
    // Hamburger View Helper Methods
    private func hideHamburgerViewWithAnimation() {
        UIView.animate(
            withDuration: 0.1,
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
                self?.hideHamburgerView()
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
                withDuration: 0.1,
                animations: { [weak self] in
                    self?.hamburgerLeadingConstraint.constant = 0
                    self?.view.layoutIfNeeded()
                }) { [weak self] _ in
                self?.showHamburgerView()
            }
        }
    }
    
    private func hideHamburgerView() {
        hamburgerLeadingConstraint.constant = -1.0 * hamburgerWidth.constant
        hamburgerSuperView.isHidden = true
        isHamburgerOnScreen = false
    }
    
    private func showHamburgerView() {
        hamburgerLeadingConstraint.constant = 0
        hamburgerSuperView.isHidden = false
        isHamburgerOnScreen = true
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
            if let touch = touches.first {
                let location = touch.location(in: hamburgerSuperView)
                let diff = location.x - touchesBeginPoint
                let minValue = -1 * hamburgerWidth.constant
                if diff <= 0 && diff >= minValue {
                    hamburgerLeadingConstraint.constant =  diff
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isHamburgerOnScreen {
            if let touch = touches.first {
                let location = touch.location(in: hamburgerSuperView)
                let diff = location.x - touchesBeginPoint
                let minValue = -1.0 * hamburgerWidth.constant
                
                guard diff <= 0, diff >= minValue else {
                    return
                }
                let shouldHide = abs(diff) > (hamburgerWidth.constant * 0.30)
                
                if !shouldHide {
                    hamburgerSuperView.isHidden = true
                }
                
                UIView.animate(withDuration: 0.1,
                               animations: {[weak self] in
                                if shouldHide {
                                    self?.hideHamburgerView()
                                    self?.view.layoutIfNeeded()
                                }
                                else {
                                    self?.showHamburgerView()
                                    self?.view.layoutIfNeeded()
                                }
                               })
            }
        }
    }
}

extension ChatListMultiViewController: ChatListViewProtocol {
    func didSelectChatFromChatList(viewData: [String: Any]) {
        let vc = ChatViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}
