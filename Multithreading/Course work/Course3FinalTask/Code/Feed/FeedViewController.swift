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
                
        feedTableView.dataSource = self
        feedTableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        blockView.show()
        
        getFeedPosts { [weak self] (feedPosts) in
            
            guard let `self` = self else { return }
            
            guard let feedPosts = feedPosts else {
                let alert = ErrorAlertController(parentVC: self)
                alert.show()
                self.blockView.hide()
                return
            }
            
            DispatchQueue.main.async {
                self.feedPosts = feedPosts
                self.feedTableView.reloadData()
                self.blockView.hide()
            }
        }
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
    
    /// Обновление данных массива постов ленты (вызывается после лайка / анлайка).
    func updateFeedData() {
        
        getFeedPosts { [weak self] (feedPosts) in
            
            guard let `self` = self else { return }
            
            guard let feedPosts = feedPosts else {
                let alert = ErrorAlertController(parentVC: self)
                alert.show()
                return
            }
            
            self.feedPosts = feedPosts
        }
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
    private func getFeedPosts(completion: @escaping ([Post]?) -> Void) {
        DataProviders.shared.postsDataProvider.feed(queue: .global(qos: .userInitiated)) {
            (feedPosts) in
            
            completion(feedPosts)
        }
    }
}
