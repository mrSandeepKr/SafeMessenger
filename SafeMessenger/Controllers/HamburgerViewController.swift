//
//  HamburgerViewController.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 29/05/21.
//

import UIKit

protocol HamburgerViewProtocol: AnyObject {
    func shouldShowProfileCard()
    func shouldShowAboutView()
}

class HamburgerViewController: UIViewController {
    private var viewModel = HamburgerViewModel()
    private var logInObserver: NSObjectProtocol?
    weak var delegate: HamburgerViewProtocol?
    
    private lazy var profileImageView : UIImageView = {
        let image = UIImage(named: viewModel.profileImageName)
        let imageView = UIImageView(image: image)
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private lazy var userNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var emailLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = UIColor(cgColor: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1))
        label.textAlignment = .center
        label.text = "johndoe@gmail.com"
        return label
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
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.reusableIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.alpha = 0.99
        view.backgroundColor = UIColor(patternImage: UIImage(named: viewModel.hamburgerBackgroundImageName)!)
        
        logInObserver = NotificationCenter.default.addObserver(forName: .didLogInNotification,
                                                               object: nil,
                                                               queue: .main,
                                                               using: { [weak self] _ in
                                                                guard let strongSelf = self else {
                                                                    return
                                                                }
                                                                strongSelf.basicUISetUp()
                                                               })
        view.addSubview(profileImageView)
        view.addSubview(signOutBtn)
        view.addSubview(userNameLabel)
        view.addSubview(emailLabel)
        view.addSubview(tableView)
        
        basicUISetUp()
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
        userNameLabel.sizeToFit()
        emailLabel.sizeToFit()
        userNameLabel.frame = CGRect(x: 0,
                                     y: profileImageView.bottom + 30,
                                     width: view.width,
                                     height: userNameLabel.height)
        emailLabel.frame = CGRect(x: 0,
                                  y: userNameLabel.bottom + 5,
                                  width: view.width,
                                  height: emailLabel.height)
        
        tableView.frame = CGRect(x: 0,
                                 y: emailLabel.bottom + 30,
                                 width: view.width,
                                 height: 300)
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
    
    @objc private func profileBtnTapped() {
        delegate?.shouldShowProfileCard()
    }
    
    private func basicUISetUp() {
        viewModel.updateProfileImageView(for: profileImageView)
        userNameLabel.text = viewModel.userNameLabelString()
        emailLabel.text = viewModel.emailLabelString()
    }
}

extension HamburgerViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.tableViewData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.reusableIdentifier)
        else {
            return UITableViewCell()
        }
        cell.backgroundColor = .clear
        cell.textLabel?.attributedText = viewModel.getAttributedString(for: viewModel.tableViewData[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellType = viewModel.tableViewData[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        switch cellType {
        case .account:
            delegate?.shouldShowProfileCard()
        case .about:
            delegate?.shouldShowAboutView()
            break
        case .settings:
            break
        case .blockedContacts:
            break
        }
    }
}
