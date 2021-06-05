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
        return table
    }()
    
    private lazy var spinner = JGProgressHUD(style: .dark)

    private lazy var noChatsLabel: UILabel = {
        let label = UILabel()
        label.text = "No Conversations!"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 25, weight: .medium)
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
        viewModel.fetchData { success in
            if success {
                tableView.isHidden = false
            }
        }
        view.backgroundColor = .clear
        
        view.addSubview(tableView)
        view.addSubview(noChatsLabel)
        setUpTableView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = CGRect(x: 0, y: 0, width: view.width, height: view.height)
        //TODO:
        // Add tableview via anchors could be easier to control.
        // 1. Add the no chats label.
        // 2. Add Spinner for no chats area.
    }
}

extension ChatListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.reusableIdentifier) else {
            return UITableViewCell()
        }
        cell.textLabel?.text = "Hi Brooo"
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    private func setUpTableView() {
        tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: UITableViewCell.reusableIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.didSelectChatFromChatList(viewData: [:])
    }
}

