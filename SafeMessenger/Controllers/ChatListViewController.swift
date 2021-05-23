//
//  ChatListViewController.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 21/05/21.
//

import UIKit

class ChatListViewController: UIViewController {
    private let viewModel = ChatListViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        
        if !viewModel.isLoggedIn {
            presetLoginScreen()
        }
    }
}

extension ChatListViewController {
    private func presetLoginScreen() {
        let vc = LogInViewController()
        vc.navigationItem.largeTitleDisplayMode = .always
        self.navigationController?.pushViewController(vc, animated: false)
    }
}
