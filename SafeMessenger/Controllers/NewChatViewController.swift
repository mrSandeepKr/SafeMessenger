//
//  NewChatViewController.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 21/05/21.
//

import UIKit
import JGProgressHUD

class NewChatViewController: UIViewController {
    private lazy var searchBar : UISearchBar = {
        let bar = UISearchBar()
        bar.placeholder = "Search for users"
        return bar
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.isHidden = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.reusableIdentifier)
        return tableView
    }()
    
    private lazy var spinner = JGProgressHUD(style: .dark)
    
    private lazy var noResultLabel: UILabel = {
        let label = UILabel()
        label.text = "No Results"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 22, weight: .medium)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        navigationController?.navigationBar.topItem?.titleView = searchBar
        searchBar.becomeFirstResponder()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(dismissSearchView))
    }
    
    @objc private func dismissSearchView() {
        dismiss(animated: true)
    }
}

extension NewChatViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        return
    }
}
