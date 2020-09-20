//
//  MainViewController.swift
//  Course2FinalTask
//
//  Created by User on 22.07.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import Foundation
import UIKit
import DataProvider

class FeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Свойства
    /// Массив постов ленты
    private lazy var feedPosts = DataProviders.shared.postsDataProvider.feed()
    
    @IBOutlet weak var feedTableView: UITableView!
    
    // MARK: - Методы жизненного цикла
    override func viewDidLoad() {
        super.viewDidLoad()
        
        feedTableView.dataSource = self
        feedTableView.delegate = self
        feedTableView.separatorStyle = .none
    }
    
    // MARK: - CollectionViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! FeedTableViewCell
        cell.fillingCell(feedPosts[indexPath.row])
        cell.delegate = self
        return cell
    }
}

// MARK: - FeedTableViewCellDelegate
extension FeedViewController: FeedTableViewCellDelegate {
    
    /// Переход в профиль автора поста
    func tapAuthorOfPost(user: User) {
        guard let profileVC = storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as? ProfileViewController else { return }
        profileVC.user = user
        show(profileVC, sender: nil)
    }
    
    /// Переход на экран лайкнувших пост пользователей
    func tapLikesCountLabel(userList: [User]) {
        let likesCV = UserListViewController(userList: userList)
        likesCV.title = "Likes"
        show(likesCV, sender: nil)
    }
    
    /// Обновление данных массива постов ленты
    func updateFeedData() {
        feedPosts = DataProviders.shared.postsDataProvider.feed()
    }
}
