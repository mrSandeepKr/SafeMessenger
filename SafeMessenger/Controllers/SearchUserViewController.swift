//
//  SearchUserViewController.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 21/05/21.
//

import UIKit
import JGProgressHUD

protocol SearchUserViewProtocol: AnyObject {
    func openChatForUser(user:User)
}

class SearchUserViewController: UIViewController {
    
    //MARK: Elements
    private lazy var searchBar : UISearchBar = {
        let bar = UISearchBar()
        bar.placeholder = "Search for users"
        return bar
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.isHidden = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.reusableIdentifier)
        return tableView
    }()
    
    private lazy var spinner = JGProgressHUD(style: .dark)
    
    private lazy var noResultLabel: UILabel = {
        let label = UILabel()
        label.text = "No Results"
        label.isHidden = true
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 22, weight: .medium)
        return label
    }()
    
    private lazy var usersSet = UsersList()
    private lazy var results = UsersList()
    private lazy var areResultsFetch = false
    private var viewModel: SearchUserViewModel!
    weak var delegate: SearchUserViewProtocol?
    
    //MARK: LifeCycle
    init(viewModel: SearchUserViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        searchBar.delegate = self
        searchBar.becomeFirstResponder()
        
        //TODO: Move to private func
        viewModel.updateUserList {[weak self] userList in
            DispatchQueue.main.async {
                self?.usersSet = userList
                self?.areResultsFetch = true
            }
        }
        
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(dismissSearchView))
        
        view.addSubview(tableView)
        view.addSubview(noResultLabel)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        noResultLabel.sizeToFit()
        noResultLabel.frame = CGRect(x: 0, y: 0, width: noResultLabel.width, height: noResultLabel.height)
        noResultLabel.center = view.center
    }
    
    override func viewDidAppear(_ animated: Bool) {
        hideAllElements()
    }
    
    private func hideAllElements() {
        noResultLabel.isHidden = true
        tableView.isHidden = true
    }
}

extension SearchUserViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.reusableIdentifier) as? UITableViewCell,
              let text = results[indexPath.row][Constants.name] as? String
        else {
            return UITableViewCell()
        }
        cell.textLabel?.text = text
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedUser: User = results[indexPath.row]
        dismiss(animated: true) {[weak self] in
            self?.delegate?.openChatForUser(user: selectedUser)
        }
    }
}

extension SearchUserViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        hideAllElements()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text?.replacingOccurrences(of: " ", with: ""), !searchText.isEmpty, areResultsFetch else {
            return
        }
        self.searchUsers(query: searchText.lowercased())
        updateUIPostSearch()
    }
    
    private func searchUsers(query: String) {
        self.results = self.usersSet.filter { user in
            guard let name = user[Constants.name] as? String,
                  let em = user[Constants.email] as? String else {
                return false
            }
            let email = em.lowercased()
            let split = name.lowercased().split(separator: " ")
            let fn = split.count > 0 ? split[0] : ""
            let sn = split.count > 1 ? split[1] : ""
            return fn.hasPrefix(query) || sn.hasPrefix(query) || email.hasPrefix(query)
        }
    }
    
    private func updateUIPostSearch() {
        if results.count == 0 {
            tableView.isHidden = true
            noResultLabel.isHidden = false
        }
        else {
            tableView.isHidden = false
            noResultLabel.isHidden = true
            tableView.reloadData()
        }
    }
    
    @objc private func dismissSearchView() {
        dismiss(animated: true)
    }
}