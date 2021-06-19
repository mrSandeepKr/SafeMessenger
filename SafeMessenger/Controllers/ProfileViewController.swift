//
//  ProfileViewController.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 21/05/21.
//

import UIKit

class ProfileViewController: UIViewController {
    private let viewModel: ProfileViewModel
    var onlineUserSetChangeObserver: NSObjectProtocol?
    
    private lazy var profileImageView : UIImageView = {
        let image = UIImage(named: viewModel.profileImageName)
        let imageView = UIImageView(image: image)
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var userNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textAlignment = .center
        label.text = "Unkown User"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var emailLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = UIColor(cgColor: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1))
        label.textAlignment = .center
        label.text = "johndoe@gmail.com"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var presenceIcon: UIImageView = {
        let imageView = UIImageView(image: viewModel.offlinePresenceImage)
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.reusableIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isHidden = true
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableFooterView = UIView(frame: .zero)
        return tableView
    }()
    
    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        view.addSubview(profileImageView)
        view.addSubview(userNameLabel)
        view.addSubview(emailLabel)
        view.addSubview(presenceIcon)
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate(getStaticConstraints())
        updateUI()
        onlineUserSetChangeObserver = NotificationCenter.default.addObserver(forName: .onlineUserSetChangeNotification,
                                                                             object: nil,
                                                                             queue: .main,
                                                                             using: {[weak self] _ in
                                                                                self?.updatePresence()
                                                                             })
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left"),
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(backButtonTapped))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.shadowImage = nil
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
    }
    
    deinit {
        guard let observer = onlineUserSetChangeObserver else {
            return
        }
        NotificationCenter.default.removeObserver(observer)
    }
    
    private func updatePresence() {
        presenceIcon.image = viewModel.isUserOnline ? viewModel.onlinePresenceImage : viewModel.offlinePresenceImage
    }
    
    private func updateUI() {
        userNameLabel.text = viewModel.personModel.displayName
        profileImageView.sd_setImage(with: viewModel.personModel.imageURL)
        emailLabel.text = viewModel.personModel.email
        presenceIcon.image = viewModel.offlinePresenceImage
        tableView.isHidden = false
        tableView.reloadData()
        updatePresence()
    }
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.reusableIdentifier)
        else {
            return UITableViewCell()
        }
        
        switch viewModel.tableData[indexPath.row] {
        case .blockContact :
            cell.textLabel?.text = "Block Contact"
            cell.textLabel?.textColor = .systemRed
            cell.textLabel?.font = .systemFont(ofSize:17, weight: .semibold)
            break
        case .blockedContactList:
            cell.textLabel?.text = "Blocked Contacts List"
            cell.textLabel?.textColor = .systemRed
            cell.textLabel?.font = .systemFont(ofSize:17, weight: .semibold)
            break
        case .settings:
            let attachment = NSTextAttachment(image: UIImage(systemName: "gear")!)
            let settings = NSAttributedString(string: " Settings")
            let completeString = NSMutableAttributedString(attachment: attachment)
            completeString.append(settings)
            cell.textLabel?.attributedText = completeString
            break
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

extension ProfileViewController {
    private func getStaticConstraints() -> [NSLayoutConstraint] {
        var constraints = [NSLayoutConstraint]()
        let profileImageTopPadding: CGFloat = (navigationController?.navigationBar.height ?? 44) * 1.5
        let profileImageSize = view.width * 0.4
        let presenceIconSize = 0.1 * profileImageSize
        let presenceIconSide = 0.09 * profileImageSize
        
        let userNameLabelHeight = view.height * 0.03
        let emailLabelHeight = userNameLabelHeight * 0.9
        
        profileImageView.layer.cornerRadius = profileImageSize * 0.5
        presenceIcon.layer.cornerRadius = presenceIconSize * 0.5

        constraints.append(contentsOf: [
            profileImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: profileImageTopPadding),
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: profileImageSize),
            profileImageView.heightAnchor.constraint(equalToConstant: profileImageSize)
        ])
        
        constraints.append(contentsOf: [
            presenceIcon.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: -1 * presenceIconSide),
            presenceIcon.trailingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: -1 * presenceIconSide),
            presenceIcon.heightAnchor.constraint(equalToConstant: presenceIconSize),
            presenceIcon.widthAnchor.constraint(equalToConstant: presenceIconSize)
        ])
        
        constraints.append(contentsOf: [
            userNameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 50),
            userNameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            userNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            userNameLabel.heightAnchor.constraint(equalToConstant: userNameLabelHeight)
        ])
        
        constraints.append(contentsOf: [
            emailLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 3),
            emailLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emailLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emailLabel.heightAnchor.constraint(equalToConstant: emailLabelHeight)
        ])
        
        constraints.append(contentsOf: [
            tableView.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        return constraints
    }
    
    @objc private func backButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
}
