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

class FeedViewController: UIViewController {
    
    // MARK: - Свойства
    /// Блокирующее вью, отображаемое во время ожидания получения данных.
    private lazy var blockView = BlockView(parentView: self.tabBarController?.view ?? self.view)
    
    /// Массив постов ленты.
    private var feedPosts = [Post]()
    
    @IBOutlet weak var feedTableView: UITableView!
        
    // MARK: - Методы жизненного цикла
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        getFeedPosts(isAfterLikeUnlike: false)
        
        feedTableView.dataSource = self
        feedTableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getFeedPosts(isAfterLikeUnlike: false)
    }
}

// MARK: - CollectionViewDataSource
extension FeedViewController: UITableViewDataSource {
    
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
    
    /// Переход в профиль автора поста.
    func tapAuthorOfPost(user: User) {
        guard let profileVC = storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as? ProfileViewController else { return }
        profileVC.user = user
        navigationController?.pushViewController(profileVC, animated: true)
    }
    
    /// Переход на экран лайкнувших пост пользователей.
    func tapLikesCountLabel(userList: [User]) {
        let likesCV = UserListViewController(userList: userList)
        likesCV.title = "Likes"
        navigationController?.pushViewController(likesCV, animated: true)
    }
    
    /// Обновление данных массива постов ленты.
    func updateFeedData() {
        getFeedPosts(isAfterLikeUnlike: true)
    }
    
    func showBlockView() {
        blockView.show()
    }
    
    func hideBlockView() {
        blockView.hide()
    }
    
    func showErrorAlert() {
        let alert = ErrorAlertController(parentVC: self)
        alert.show()
    }
}

// MARK: - Методы получения данных
extension FeedViewController {
    /// Получение публикаций пользователей, на которых подписан текущий пользователь.
    private func getFeedPosts(isAfterLikeUnlike: Bool) {
        
        // Блокирующее вью запустится если функция вызвана не после лайка/анлайка
        if !isAfterLikeUnlike {
            blockView.show()
        }
        
        DataProviders.shared.postsDataProvider.feed(queue: .global(qos: .userInitiated)) { (feedPosts) in
            
            guard let feedPosts = feedPosts else {
                let alert = ErrorAlertController(parentVC: self)
                alert.show()
                return
            }
            
            DispatchQueue.main.async {
                self.feedPosts = feedPosts
                
                // Если обновление массива постов вызвано после лайков, то reloadData не вызывается
                if !isAfterLikeUnlike {
                    self.feedTableView.reloadData()
                    self.blockView.hide()
                } else {
                    //                    print("Feed updated!")
                }
            }
        }
    }
}
