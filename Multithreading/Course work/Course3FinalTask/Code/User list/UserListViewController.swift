//
//  YellowViewController.swift
//  Course2FinalTask
//
//  Created by User on 09.08.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit
import DataProvider

class UserListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Свойства
    /// Список пользователей для отображения в таблице.
    private var userList: [User] = []
    
    private lazy var userListTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    // MARK: - Инициализаторы
    convenience init(userList: [User]) {
        self.init()
        self.userList = userList
    }
    
    // MARK: - Методы жизненного цикла
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupConstraints()
        userListTableView.dataSource = self
        userListTableView.delegate = self
    }
    
    // Снятие выделения с ячейки при возврате на вью
    override func viewDidAppear(_ animated: Bool) {
        guard let selectedRow = userListTableView.indexPathForSelectedRow else { return }
        userListTableView.deselectRow(at: selectedRow, animated: true)
    }
    
    // MARK: - Layout
    private func setupUI() {
        view.addSubview(userListTableView)
    }
    
    private func setupConstraints() {
        let constraints = [
            userListTableView.topAnchor.constraint(equalTo: view.topAnchor),
            userListTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            userListTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            userListTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: - TableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        userList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.imageView?.image = userList[indexPath.row].avatar
        cell.textLabel?.text = userList[indexPath.row].fullName
        return cell
    }

    // MARK: - TableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
    // Переход на вью пользователя
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let profileVC = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as? ProfileViewController else { return }
        profileVC.user = userList[indexPath.row]
        show(profileVC, sender: nil)
    }
}
