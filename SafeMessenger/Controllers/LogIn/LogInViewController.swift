//
//  LogInViewController.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 21/05/21.
//

import UIKit
import GoogleSignIn
import JGProgressHUD

class LogInViewController: UIViewController {
    private let viewModel = LogInViewModel()
    private var logInObserver: NSObjectProtocol?
    
    //MARK: Elements
    private lazy var spinner = JGProgressHUD(style: .dark)
    
    private lazy var emailField: RounderCornerTextField = {
        let label = RounderCornerTextField(placeholder: "Enter Email..")
        label.returnKeyType = .next
        return label
    }()
    
    private lazy var passwordField: RounderCornerTextField = {
        let label = RounderCornerTextField(placeholder: "Password",
                                           isPassword: true)
        label.returnKeyType = .continue
        return label
    }()
    
    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: Constants.ImageNameLogo)
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private lazy var logInBtn: RoundedCornerButton = {
        let btn = RoundedCornerButton(cornerRad: 12,
                                      btnTitle: "Log In",
                                      btnColor: .systemBlue,
                                      borderColor: UIColor.label)
        btn.addTarget(self, action: #selector(didTapSignInBtn), for: .touchUpInside)
        return btn
    }()
    
    class googleSignInButtonView: UIView {
        private lazy var titleView: UILabel = {
            let title = UILabel()
            title.textColor = UIColor(cgColor: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1))
            title.text = "Sign In"
            title.font = .systemFont(ofSize: 17, weight: .medium)
            title.textAlignment = .left
            return title
            
        }()
        
        private lazy var imageView :UIImageView = {
            let imageView = UIImageView(image: UIImage(named: Constants.ImageNameGoogleIcon))
            imageView.contentMode = .scaleAspectFit
            return imageView
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            backgroundColor = UIColor.init(cgColor: #colorLiteral(red: 0.9162556529, green: 0.9164093733, blue: 0.9162355065, alpha: 1))
            layer.borderWidth = 1
            layer.borderColor = UIColor.lightGray.cgColor
            layer.cornerRadius = 5
            
            addSubview(titleView)
            addSubview(imageView)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            titleView.sizeToFit()
            let imageSize = height * 0.8
            let pad: CGFloat = 10.0
            let imageTop = (height - imageSize) / 2.0
            let imageLeft = (width - (imageSize + pad + titleView.width)) / 2.0
            imageView.frame = CGRect(x: imageLeft, y: imageTop, width: imageSize, height: imageSize)
            titleView.frame = CGRect(x: imageView.right + pad, y: 0, width: titleView.width, height: height)
        }
    }
    
    private lazy var googleSignInButton = googleSignInButtonView()
    
    private lazy var createAccountBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.backgroundColor = .systemBackground
        btn.setTitle("Create Account?", for: .normal)
        btn.setTitleColor(.link, for: .normal)
        btn.addTarget(self, action: #selector(didTapCreateAccount), for: .touchUpInside)
        btn.contentHorizontalAlignment = .center
        return btn
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        emailField.delegate = self
        passwordField.delegate = self
        GIDSignIn.sharedInstance().presentingViewController = self
        
        logInObserver = NotificationCenter.default.addObserver(forName: .didLogInNotification,
                                                               object: nil,
                                                               queue: .main,
                                                               using: { [weak self] _ in
                                                                self?.spinner.dismiss()
                                                                self?.navigationController?.dismiss(animated: true)
                                                               })
        googleSignInButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapGoogleSignIn)))
        
        view.addSubview(logoImageView)
        view.addSubview(scrollView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(logInBtn)
        scrollView.addSubview(createAccountBtn)
        scrollView.addSubview(googleSignInButton)
        
        addKeyboardDismissGesture()
    }
    
    deinit {
        if let observer = logInObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        emailField.becomeFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let logoSize = view.width/3
        scrollView.frame = view.bounds
        logoImageView.frame = CGRect(x: (view.width-logoSize)/2,
                                     y: view.safeAreaInsets.top - 6,
                                     width: logoSize,
                                     height: logoSize)
        
        emailField.frame = CGRect(x: view.width/15,
                                  y: logoImageView.bottom + view.height/10,
                                  width:  (13.0/15.0) * view.width,
                                  height: logoSize/3)
        
        passwordField.frame = CGRect(x: emailField.left,
                                     y: emailField.bottom + 10,
                                     width: emailField.width,
                                     height: emailField.height)
        
        let logInbtnWidth = emailField.width * 0.8
        logInBtn.frame = CGRect(x: (view.width - logInbtnWidth)/2,
                                y: passwordField.bottom + 30,
                                width: logInbtnWidth,
                                height: view.height/18)
        
        googleSignInButton.frame = CGRect(x: (view.width - logInbtnWidth * 0.95 )/2.0 ,
                                          y: logInBtn.bottom + 5,
                                          width: logInbtnWidth * 0.95,
                                          height: view.height/20)
        
        createAccountBtn.frame = CGRect(x: (view.width - logInbtnWidth * 0.95 )/2.0,
                                        y: googleSignInButton.bottom + 5,
                                        width: logInbtnWidth * 0.95,
                                        height: 30)
    }
}

extension LogInViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField {
            didTapSignInBtn()
        }
        return true
    }
}

extension LogInViewController {
    @objc private func didTapGoogleSignIn() {
        spinner.show(in: view)
        viewModel.googleSignUser()
    }
    
    @objc private func didTapCreateAccount() {
        let vc = RegisterViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func didTapSignInBtn() {
        print("LogInViewController: Attempting LogIn")
        
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        self.spinner.show(in: view)
        viewModel.logInUser(with: emailField.text,
                            password: passwordField.text) {[weak self] msg in
            self?.spinner.dismiss()
            if let alertMsg = msg, !alertMsg.isEmpty {
                self?.alertForWrongLogin(msg: alertMsg)
                return
            }
            
            print("LogInViewController: Successful Login")
            NotificationCenter.default.post(name: .didLogInNotification, object: nil)
            self?.dismiss(animated: true)
        }
    }
    
    private func alertForWrongLogin(msg: String) {
        print("LoginViewController: email or password were empty")
        let alert = UIAlertController(title: "Oops..",
                                      message: msg,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .destructive, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func addKeyboardDismissGesture() {
        let tap: UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}
