//
//  AboutViewController.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 20/06/21.
//

import UIKit

class AboutViewController: UIViewController {
    private let viewModel: AboutViewModel
    
    init(viewModel: AboutViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var aboutMessageTitle: UILabel = {
        let label = UILabel()
        label.text = "Write something about yourself"
        label.textAlignment = .center
        label.textColor = .systemGray6
        label.font = .systemFont(ofSize: 13, weight: .regular)
        return label
    }()
    
    private lazy var aboutMessageLabel: UILabel = {
        let label = UILabel()
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapAboutLabel))
        label.addGestureRecognizer(gesture)
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.isUserInteractionEnabled = true
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private lazy var aboutMessageText: UITextView = {
        let textField = UITextView()
        textField.font = .systemFont(ofSize: 16, weight: .regular)
        textField.returnKeyType = .done
        return textField
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(aboutMessageTitle)
        view.addSubview(aboutMessageLabel)
        view.addSubview(aboutMessageText)
        view.backgroundColor = .systemBackground
        self.updateUI(forEditingModel: false)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left"),
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(backButtonTapped))

        let titleLabel = UILabel()
        titleLabel.text = "About"
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        navigationItem.titleView = titleLabel
        
        viewModel.getAboutString {[weak self] success in
            self?.updateUI(forEditingModel: false)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        aboutMessageTitle.sizeToFit()
        aboutMessageTitle.frame = CGRect(x: 0, y: 30, width: view.width, height: aboutMessageTitle.height)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        makeNavigationBarTransperant()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        resetNavigationBarTrasperancy()
    }
}

extension AboutViewController {
    private func updateUI(forEditingModel: Bool) {
        if forEditingModel {
            aboutMessageText.text = viewModel.aboutMessage
            aboutMessageLabel.isHidden = true
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done",
                                                                style: .done,
                                                                target: self,
                                                                action: #selector(doneButtonTapped))
            
            aboutMessageText.isHidden = false
            aboutMessageText.becomeFirstResponder()
        }
        else {
            aboutMessageLabel.text = viewModel.aboutMessage
            aboutMessageText.resignFirstResponder()
            aboutMessageText.isHidden = true
            
            navigationItem.rightBarButtonItem = nil
            aboutMessageLabel.isHidden = false
        }
        let leftPadding: CGFloat = 30.0
        let width = view.width - (2.0 * leftPadding)
        let labelSize = aboutMessageLabel.sizeThatFits(CGSize(width: width, height: 500))
        let labelTop = aboutMessageTitle.bottom + 10
        aboutMessageText.frame = CGRect(x: leftPadding, y: labelTop, width: width, height: 500)
        aboutMessageLabel.frame = CGRect(x: leftPadding, y: labelTop, width: width, height: labelSize.height)
    }
    
    @objc private func backButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func didTapAboutLabel() {
        updateUI(forEditingModel: true)
    }
    
    @objc private func doneButtonTapped() {
        guard let text = aboutMessageText.text,
              !text.isEmpty, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              text != viewModel.defaultAboutMessage
        else {
            return
        }
        
        let finalAboutString = text.replacingOccurrences(of: "\n", with: " ")
        viewModel.setAboutString(aboutString: finalAboutString) {[weak self] success in
            if success {
                print("AboutViewController: Upated About Message")
                self?.aboutMessageLabel.text = text
                self?.updateUI(forEditingModel: false)
            }
        }
        return
    }
}
