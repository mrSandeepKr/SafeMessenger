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
        table.rowHeight = UITableView.automaticDimension
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
        spinner.show(in: view)
        DispatchQueue.background( background: {[weak self] in
            self?.viewModel.fetchData {[weak self] success in
                if success {
                    DispatchQueue.main.async {
                        self?.tableView.isHidden = false
                        self?.spinner.dismiss()
                        self?.tableView.reloadData()
                    }
                }
            }
        })
        
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
    
    override func viewDidDisappear(_ animated: Bool) {
        spinner.dismiss()
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
        delegate?.didSelectChatFromChatList(viewData: [:])
    }
}

