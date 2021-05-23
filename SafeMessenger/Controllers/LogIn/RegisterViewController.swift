//
//  RegisterViewController.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 21/05/21.
//

import UIKit

class RegisterViewController: UIViewController {
    
    private var viewModel = RegisterViewModel()
    
    //MARK: Elements
    private lazy var backgroundImage: UIImageView = {
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        
        backgroundImage.image = viewModel.backgroundImage
        backgroundImage.contentMode = UIView.ContentMode.scaleAspectFill
        return backgroundImage
    }()
    
    private lazy var profileImage: UIImageView = {
        let imageView = UIImageView(image: viewModel.profileImage)
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = view.width/6
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UITraitCollection.current.userInterfaceStyle == .dark ?
            UIColor.white.cgColor : UIColor(cgColor: #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1)).cgColor
        return imageView
    }()
    
    private lazy var firstName: UnderlinedTextField = {
        let textField = UnderlinedTextField(lineThickness: 1,
                                            placeholder: "First Name",
                                            lineColor: UIColor.init(cgColor: #colorLiteral(red: 0.1215686277, green: 0.01176470611, blue: 0.4235294163, alpha: 1)),
                                            returnKeyType: .next)
        textField.backgroundColor = .clear
        return textField
    }()
    
    private lazy var secondName: UnderlinedTextField = {
        let textField = UnderlinedTextField(lineThickness: 1,
                                            placeholder: "Second Name",
                                            lineColor: UIColor.init(cgColor: #colorLiteral(red: 0.1215686277, green: 0.01176470611, blue: 0.4235294163, alpha: 1)),
                                            returnKeyType: .next)
        textField.backgroundColor = .clear
        return textField
    }()
    
    private lazy var emailField: UnderlinedTextField = {
        let textField = UnderlinedTextField(lineThickness: 1,
                                            placeholder: "Email Address...",
                                            lineColor: UIColor.init(cgColor: #colorLiteral(red: 0.1215686277, green: 0.01176470611, blue: 0.4235294163, alpha: 1)),
                                            returnKeyType: .next)
        textField.backgroundColor = .clear
        return textField
    }()
    
    private lazy var passwordField: UnderlinedTextField = {
        let textField = UnderlinedTextField(lineThickness: 1,
                                            placeholder: "Choose Password...",
                                            lineColor: UIColor.init(cgColor: #colorLiteral(red: 0.1215686277, green: 0.01176470611, blue: 0.4235294163, alpha: 1)),
                                            returnKeyType: .next,
                                            isPassword: true)
        textField.backgroundColor = .clear
        return textField
    }()
    
    private lazy var verifyPasswordField: UnderlinedTextField = {
        let textField = UnderlinedTextField(lineThickness: 1,
                                            placeholder: "Verify Password...",
                                            lineColor: UIColor.init(cgColor: #colorLiteral(red: 0.1215686277, green: 0.01176470611, blue: 0.4235294163, alpha: 1)),
                                            returnKeyType: .continue,
                                            isPassword: true)
        textField.backgroundColor = .clear
        return textField
    }()
    
    private lazy var createAccountBtn: RoundedCornerButton = {
        let btn = RoundedCornerButton(cornerRad: 12,
                                      btnTitle: "Create Account",
                                      btnColor: .systemBlue,
                                      borderColor: UIColor.label)
        btn.addTarget(self, action: #selector(didTapCreateAccount), for: .touchUpInside)
        return btn
    }()
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Register Account"
        
        view.addSubview(backgroundImage)
        view.addSubview(profileImage)
        view.addSubview(firstName)
        view.addSubview(secondName)
        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(verifyPasswordField)
        view.addSubview(createAccountBtn)
        
        firstName.delegate = self
        secondName.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        verifyPasswordField.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setUpLayout()
        addKeyboardDismissGesture()
        addProfilePicGestureRecogniser()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addProfilePicGestureRecogniser()
        let _ = firstName.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isMovingFromParent {
            UIView.animate(withDuration: TimeInterval(1000)) {[weak self] in
                self?.view.subviews.forEach({
                    $0.removeFromSuperview()
                })
            }
        }
    }
}

extension RegisterViewController {
    @objc private func didTapCreateAccount() {
        viewModel.handleAccountCreation(firstName: firstName.text,
                                        secondName: secondName.text,
                                        email: emailField.text,
                                        password: passwordField.text,
                                        verifyPassword: verifyPasswordField.text) { [weak self] msg in
            guard msg.isEmpty else {
                self?.showAlertWithMessage(msg: msg)
                return
            }
            self?.navigationController?.popToRootViewController(animated: false)
        }
    }
    
    private func showAlertWithMessage(msg: String) {
        if msg.isEmpty {
            return
        }
        print("RegisterViewController: Create Account failed with \(msg)")
        let alert = UIAlertController(title: "Somethings Wrong", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Retry!!", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func setUpLayout() {
        let profileImageSize = view.width / 3
        let textFieldWidth = (13.0/15.0) * view.width
        let textFieldHeight = view.width / 9
        let textFieldLeft = (view.width - textFieldWidth)/2
        let createAccountBtnWidth = (11.0/15.0) * view.width
        let createAccountBtnLeft = (view.width - createAccountBtnWidth)/2
        let firstAndSecondNamePadding: CGFloat = 10
        
        profileImage.frame = CGRect(x: (view.width - profileImageSize)/2,
                                    y: view.safeAreaInsets.top + 40,
                                    width: profileImageSize,
                                    height: profileImageSize)
        firstName.frame = CGRect(x: textFieldLeft,
                                 y: profileImage.bottom + 20,
                                 width: (textFieldWidth - firstAndSecondNamePadding)/2,
                                 height: textFieldHeight)
        secondName.frame = CGRect(x: firstName.right + firstAndSecondNamePadding,
                                  y: profileImage.bottom + 20,
                                  width: (textFieldWidth - firstAndSecondNamePadding)/2,
                                  height: textFieldHeight)
        emailField.frame = CGRect(x: textFieldLeft,
                                  y: secondName.bottom + 10,
                                  width: textFieldWidth,
                                  height: textFieldHeight)
        passwordField.frame = CGRect(x: textFieldLeft,
                                     y: emailField.bottom + 10,
                                     width: textFieldWidth,
                                     height: textFieldHeight)
        verifyPasswordField.frame = CGRect(x: textFieldLeft,
                                           y: passwordField.bottom + 10,
                                           width: textFieldWidth,
                                           height: textFieldHeight)
        createAccountBtn.frame = CGRect(x: createAccountBtnLeft,
                                        y: verifyPasswordField.bottom + 40,
                                        width: createAccountBtnWidth,
                                        height: textFieldHeight * 1.3)
    }
    
    private func addKeyboardDismissGesture() {
        let tap: UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func addProfilePicGestureRecogniser() {
        let tap: UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapProfileImageView))
        profileImage.isUserInteractionEnabled = true
        profileImage.addGestureRecognizer(tap)
    }
    
    @objc private func didTapProfileImageView() {
        presentProfileImagePicker()
    }
}

extension RegisterViewController: UnderlinedTextFieldDelegate {
    func underlineTextFieldShouldReturn(_ sender: UnderlinedTextField) -> Bool {
        var res = false
        if sender == firstName {
            res = secondName.becomeFirstResponder()
        }
        else if sender == secondName {
            res = emailField.becomeFirstResponder()
        }
        else if sender == emailField {
            res = passwordField.becomeFirstResponder()
        }
        else if sender == passwordField {
            res = verifyPasswordField.becomeFirstResponder()
        }
        else if sender == verifyPasswordField {
            verifyPasswordField.resignFirstResponder()
            didTapCreateAccount()
        }
        
        return res
    }
}

extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func presentProfileImagePicker() {
        let actionSheet = UIAlertController(title: "Profile Picture",
                                            message: "How would you like to select a picture",
                                            preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Camera",style: .default,handler: {[weak self] _ in
            self?.presentCamera()
        }))
        actionSheet.addAction(UIAlertAction(title: "Choose Image", style: .default, handler: {[weak self] _ in
            self?.presentPhotoPicker()
        }))
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    private func presentCamera() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    private func presentPhotoPicker() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let selectedImage = info[.editedImage] as? UIImage else {
            return
        }
        profileImage.image = selectedImage
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
