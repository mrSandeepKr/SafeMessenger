//
//  LogInViewController.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 21/05/21.
//

import UIKit

class LogInViewController: UIViewController {
    //MARK: Elements
    private lazy var emailTextField: RounderCornerTextField = {
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
        emailTextField.delegate = self
        passwordField.delegate = self
        
        view.addSubview(logoImageView)
        view.addSubview(scrollView)
        scrollView.addSubview(emailTextField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(logInBtn)
        scrollView.addSubview(createAccountBtn)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let logoSize = view.width/3
        scrollView.frame = view.bounds
        logoImageView.frame = CGRect(x: (view.width-logoSize)/2,
                                     y: view.safeAreaInsets.top - 6,
                                     width: logoSize,
                                     height: logoSize)
        
        emailTextField.frame = CGRect(x: view.width/15,
                                      y: logoImageView.bottom + view.height/10,
                                      width:  (13.0/15.0) * view.width,
                                      height: logoSize/3)
        
        passwordField.frame = CGRect(x: emailTextField.left,
                                     y: emailTextField.bottom + 10,
                                     width: emailTextField.width,
                                     height: emailTextField.height)
        
        let logInbtnWidth = emailTextField.width * 0.8
        logInBtn.frame = CGRect(x: (view.width - logInbtnWidth)/2,
                                y: passwordField.bottom + 30,
                                width: logInbtnWidth,
                                height: view.height/18)
        
        createAccountBtn.frame = CGRect(x: 0,
                                        y: logInBtn.bottom + 5,
                                        width: view.width,
                                        height: 30)
    }
}

extension LogInViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField {
            didTapSignInBtn()
        }
        return true
    }
}

extension LogInViewController {
    @objc private func didTapCreateAccount() {
        let vc = RegisterViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func didTapSignInBtn() {
        print("LogInViewController: Attempting LogIn")
        
        emailTextField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let email = emailTextField.text, let pswd = passwordField.text,
              !email.isEmpty, !pswd.isEmpty
        else {
            alertForWrongLogin()
            return
        }
    }
    
    private func alertForWrongLogin() {
        print("LoginViewController: email or password were empty")
        let alert = UIAlertController(title: "Oops..",
                                      message: "User email and password can't be empty",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .destructive, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
