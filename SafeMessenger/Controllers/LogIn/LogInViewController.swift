//
//  LogInViewController.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 21/05/21.
//

import UIKit
import GoogleSignIn

class LogInViewController: UIViewController {
    private let viewModel = LogInViewModel()
    private var logInObserver: NSObjectProtocol?
    
    //MARK: Elements
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
        imageView.image = UIImage(named: "logo")
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
    
    private lazy var googleSignInButton : UIButton = {
        let btn = UIButton()
        btn.backgroundColor = UIColor.init(cgColor: #colorLiteral(red: 0.9162556529, green: 0.9164093733, blue: 0.9162355065, alpha: 1))
        btn.setTitleShadowColor(.blue, for: .normal)
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.lightGray.cgColor
        btn.layer.cornerRadius = 5
        
        btn.setTitleColor(UIColor(cgColor: #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)), for: .normal)
        btn.setTitle("Google Sign In", for: .normal)
        btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 0)
        btn.contentHorizontalAlignment = .left
       
        btn.setImage(UIImage(named: "googleIcon"), for: .normal)
        btn.imageEdgeInsets =  UIEdgeInsets(top: 29.5, left: 30, bottom: 29.5, right: 200)
        
        btn.addTarget(self, action: #selector(didTapGoogleSignIn), for: .touchUpInside)
        return btn
    }()
    
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
                                                               object: nil, queue: .main, using: { [weak self] _ in
                                                                self?.viewModel.setUserDefaultsForLogin()
                                                                self?.navigationController?.dismiss(animated: true)
                                                               })
        
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
        
        //TODO: Move all logic into a View Model
        viewModel.logInUser(with: emailField.text,
                            password: passwordField.text) {[weak self] msg in
            if let alertMsg = msg, !alertMsg.isEmpty {
                self?.alertForWrongLogin(msg: alertMsg)
                return
            }
            
            print("LogInViewController: Successful Login")
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
