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
    /// Массив постов ленты.
    private var feedPosts = [Post]()
    
    @IBOutlet weak var feedTableView: UITableView!
    
    /// Блокирующее вью, отображаемое во время одижания получения данных.
    let blockView = BlockView()
        
    // MARK: - Методы жизненного цикла
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let parentViewForBlockView = self.tabBarController?.view else { return }
        self.blockView.parentView = parentViewForBlockView
        blockView.setup()
        
        getFeedPosts()
        
        feedTableView.dataSource = self
        feedTableView.delegate = self
        feedTableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getFeedPosts()
    }
    
    // MARK: - Методы получения данных
    /// Получение публикаций пользователей, на которых подписан текущий пользователь.
    private func getFeedPosts() {
        
        // Блокирующее вью запустится только если функция вызвана из главного потока
        if Thread.current == .main {
            blockView.show()
        }
        
        DataProviders.shared.postsDataProvider.feed(queue: .global(qos: .userInitiated)) { (feedPosts) in
            
            guard let feedPosts = feedPosts else { return }
            
            DispatchQueue.main.async {
                self.feedPosts = feedPosts
                self.feedTableView.reloadData()
                self.blockView.hide()
            }
        }
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
    
    /// Переход в профиль автора поста.
    func tapAuthorOfPost(user: User) {
        guard let profileVC = storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as? ProfileViewController else { return }
        profileVC.user = user
        show(profileVC, sender: nil)
    }
    
    /// Переход на экран лайкнувших пост пользователей.
    func tapLikesCountLabel(userList: [User]) {
        let likesCV = UserListViewController(userList: userList)
        likesCV.title = "Likes"
        show(likesCV, sender: nil)
    }
    
    /// Обновление данных массива постов ленты.
    func updateFeedData() {
        // Запуск выполняется в фоновом потоке, т.к. происходит после лайка/анлайка
        DispatchQueue.global(qos: .utility).async {
            self.getFeedPosts()
        }
    }
    
    func showBlockView() {
        blockView.show()
    }
    
    func hideBlockView() {
        blockView.hide()
    }
}
