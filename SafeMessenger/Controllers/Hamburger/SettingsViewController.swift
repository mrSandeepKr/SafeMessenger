//
//  SettingsViewController.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 20/06/21.
//

import UIKit

class SettingsViewController: UIViewController {
    private let viewModel: SettingsViewModel
    
    private lazy var tableView: UITableView = {
        let tableView =  UITableView()
        tableView.register(SubtitleTableViewCell.self, forCellReuseIdentifier: SubtitleTableViewCell.reusableIdentifier)
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    init(viewModel: SettingsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        title = "Settings"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left")!,
                                                           style: .done,
                                                           target: self,
                                                           action: #selector(backButtonTapped))
        NSLayoutConstraint.activate(getStaticConstrataints())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        makeNavigationBarTransperant()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        resetNavigationBarTrasperancy()
    }
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SubtitleTableViewCell.reusableIdentifier) as? SubtitleTableViewCell
        else {
            return SubtitleTableViewCell()
        }
        switch viewModel.tableData[indexPath.row] {
        case .address(let ad):
            cell.configureCell(titleText: "Address", subTitleText: ad)
        case .phonenumber(let ph):
            cell.configureCell(titleText: "Phone Number", subTitleText: ph)
        case .secondaryEmail(let se):
            cell.configureCell(titleText: "Secondary Email", subTitleText: se)
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let alert = viewModel.getAlert(for: viewModel.tableData[indexPath.row]) {[weak self] success in
            self?.getDataAndReloadTable()
        }
        present(alert, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

extension SettingsViewController {
    private func getStaticConstrataints() -> [NSLayoutConstraint] {
        var constraints = [NSLayoutConstraint]()
        constraints.append(contentsOf: [
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        return constraints
    }
    
    @objc private func backButtonTapped() {
        dismiss(animated: true)
    }
    
    private func getDataAndReloadTable() {
        viewModel.getUserSettingsData()
        tableView.reloadData()
    }
}
