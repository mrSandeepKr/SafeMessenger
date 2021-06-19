//
//  ChatListViewController.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 21/05/21.
//

import UIKit
import JGProgressHUD

class ChatListViewController: UIViewController {
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.tableFooterView = UIView(frame: .zero);
        return table
    }()
    
    private lazy var spinner = JGProgressHUD(style: .dark)
    private var onlineUserSetChangeObserver: NSObjectProtocol?

    private lazy var noChatsLabel: UILabel = {
        let label = UILabel()
        label.text = "No Conversations!"
        label.textAlignment = .center
        label.isHidden = true
        label.font = .systemFont(ofSize: 23, weight: .medium)
        label.textColor = UIColor(cgColor: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1))
        return label
    }()
    
    private var viewModel: ChatListViewModel!
    weak var delegate: ChatListViewProtocol?
    
    init(viewModel: ChatListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        spinner.show(in: view)
        addChatListener()
        
        view.addSubview(tableView)
        view.addSubview(noChatsLabel)
        setUpTableView()
        
        onlineUserSetChangeObserver = NotificationCenter.default.addObserver(forName: .onlineUserSetChangeNotification,
                                                                             object: nil, queue: .main,
                                                                             using: {[weak self] _ in
                                                                                DispatchQueue.background(background: {[weak self] in
                                                                                    self?.getOnlineResultsAndUpdatePresence()
                                                                                })
                                                                             })
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        noChatsLabel.sizeToFit()
        
        tableView.frame = CGRect(x: 0, y: 0, width: view.width, height: view.height)
        noChatsLabel.frame = CGRect(x: 0, y: 0, width: noChatsLabel.width , height: noChatsLabel.height)
        noChatsLabel.center = CGPoint(x: view.center.x, y: 100)
        //TODO:
        // 1.Add tableview via anchors could be easier to control.
        // 2.Add Spinner for no chats area.
    }
    
    override var shouldAutomaticallyForwardAppearanceMethods: Bool {
        return true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.removeListerForConvo()
        addChatListener()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        spinner.dismiss()
        viewModel.removeListerForConvo()
    }
}

extension ChatListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.fetchedChats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ChatListTableViewCell.reusableIdentifier) as? ChatListTableViewCell
        else {
            return UITableViewCell()
        }
        cell.configureCell(with: ChatListTableViewCellViewModel(convo: viewModel.fetchedChats[indexPath.row]))
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    private func setUpTableView() {
        tableView.register(ChatListTableViewCell.self,
                           forCellReuseIdentifier: ChatListTableViewCell.reusableIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.didSelectChatFromChatList(with: viewModel.fetchedChats[indexPath.row])
    }
}

extension ChatListViewController {
    private func updateUIForFetch(if success:Bool) {
        if success {
            DispatchQueue.main.async {
                self.tableView.isHidden = false
                self.noChatsLabel.isHidden = true
                self.spinner.dismiss()
                self.tableView.reloadData()
            }
        }
        else {
            DispatchQueue.main.async {
                self.tableView.isHidden = true
                self.noChatsLabel.isHidden = false
                self.spinner.dismiss()
            }
        }
    }
    
    private func addChatListener() {
        viewModel.startListeningForChats {[weak self] success in
            self?.updateUIForFetch(if: success)
        }
    }
    
    private func getOnlineResultsAndUpdatePresence() {
        let configList = viewModel.getCellsUpdateOnPresenceChange()
        DispatchQueue.main.async { [weak self] in
            for config in configList {
                guard let cell = self?.tableView.cellForRow(at: config.indexpath) as? ChatListTableViewCell
                else {
                    continue
                }
                cell.updatePresenceIcon(isOnline: config.isOnline)
            }
        }
    }
}
