//
//  SearchUserViewController.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 21/05/21.
//

import UIKit
import JGProgressHUD

protocol SearchUserViewProtocol: AnyObject {
    func openChatForUser(user: ChatAppUserModel, convoID: String?)
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
        tableView.register(SearchResultTableViewCell.self, forCellReuseIdentifier: SearchResultTableViewCell.reusableIdentifier)
        return tableView
    }()
    
    private lazy var noResultLabel: UILabel = {
        let label = UILabel()
        label.text = "No Results"
        label.isHidden = true
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 22, weight: .medium)
        return label
    }()
    
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
        searchBar.becomeFirstResponder()
        hideAllElements()
    }
}

extension SearchUserViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultTableViewCell.reusableIdentifier) as? SearchResultTableViewCell
        else {
            return SearchResultTableViewCell()
        }
        cell.configureCell(with: viewModel.results[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedUser: SearchUserModel = viewModel.results[indexPath.row]
        dismiss(animated: true) {[weak self] in
            self?.delegate?.openChatForUser(user: selectedUser,
                                            convoID: self?.viewModel.getConvoIdForUser(with: selectedUser.email))
        }
    }
}

extension SearchUserViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let searchText = searchBar.text?.replacingOccurrences(of: " ", with: ""),!searchText.isEmpty
        else {
            hideAllElements()
            return
        }
        viewModel.searchUsers(query: searchText.lowercased())
        updateUIPostSearch()
    }
    
    private func updateUIPostSearch() {
        if viewModel.results.count == 0 {
            hideAllElements()
        }
        else {
            tableView.isHidden = false
            noResultLabel.isHidden = true
            tableView.reloadData()
        }
    }
    
    private func hideAllElements() {
        noResultLabel.isHidden = true
        tableView.isHidden = true
    }
    
    @objc private func dismissSearchView() {
        dismiss(animated: true)
    }
}
