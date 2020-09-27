//
//  User.swift
//  Course2FinalTask
//
//  Created by User on 04.08.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import Foundation
import UIKit
import DataProvider

class ProfileViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var profileCollectionView: UICollectionView!
    
    // MARK: - Свойства
    /// Массив фотографий постов пользователя.
    lazy var photosOfUser = [UIImage]()
    
    /// Пользователь, данные которого отображает вью.
    var user: User?
    
    /// Логическое значение, указывающее, является ли отображаемый профиль, профилем текущего пользователя.
    var isCurrentUser = true
    
    /// Блокирующее вью, отображаемое во время одижания получения данных.
    let blockView = BlockView()
    
    // MARK: - Методы жизненного цикла
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let parentViewForBlockView = self.tabBarController?.view else { return }
        self.blockView.parentView = parentViewForBlockView
        blockView.setup()
        
        profileCollectionView.register(UINib(nibName: "ProfileCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "photoCell")
        profileCollectionView.register(UINib(nibName: "HeaderProfileCollectionView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerProfile")
        
        profileCollectionView.dataSource = self
        profileCollectionView.delegate = self
        
        blockView.show()
        
        // Если user == nil, значит отображается начальный экран профиля текущего пользователя
        guard let user = user else {
            
            getCurrentUser { (currentUser) in
                    
                DispatchQueue.main.async {
                    guard let currentUser = currentUser else { return }
                    
                    self.user = currentUser
                    self.navigationItem.title = currentUser.username
                    self.getPhotos(user: currentUser)
                }
            }
            return
        }
        
        // Если исполнение долшо до сюда, значит это не стартовый экран профиля
        getCurrentUser { (currentUser) in
            guard let currentUser = currentUser else { return }
            
            // Проверка того, является ли открываемый профиль пользователя профилем текущего пользователя
            if user.id != currentUser.id {
                self.isCurrentUser = false
            }
            
            DispatchQueue.main.async {
                self.navigationItem.title = user.username
                self.getPhotos(user: user)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        blockView.show()
        
        // Обновление данных об отображаемом пользователе
        getUser { (updatedUser) in
            
            guard let updatedUser = updatedUser else { return }
            
            self.user = updatedUser
                        
            self.profileCollectionView.reloadData()
        }
    }
    
    // MARK: - Методы получения данных
    /// Получение текущего пользователя.
    private func getCurrentUser(complition: @escaping (_ currentUser: User?) -> Void) {
                
        DataProviders.shared.usersDataProvider.currentUser(queue: .global(qos: .userInitiated)) {
            (currentUser) in
            complition(currentUser)
        }
    }
    
    /// Получение всех публикаций пользователя с переданным ID.
    private func getPhotos(user: User) {
                
        DataProviders.shared.postsDataProvider.findPosts(by: user.id, queue: .global(qos: .userInitiated)) {
            (userPosts) in
            
            if let userPosts = userPosts {
                userPosts.forEach { self.photosOfUser.append($0.image) }
                
                DispatchQueue.main.async {
                    self.profileCollectionView.reloadData()
                    self.blockView.hide()
                }
            }
        }
    }
    
    /// Получение всех подписок пользователя.
    private func getUsersFollowedByUser(with userID: User.Identifier, complition: @escaping ([User]?) -> Void) {
        
        blockView.show()
        
        DataProviders.shared.usersDataProvider.usersFollowedByUser(with: userID, queue: .global(qos: .userInteractive)) {
            (usersFollowedByUser) in
                        
            DispatchQueue.main.async {
                complition(usersFollowedByUser)
                self.blockView.hide()
            }
        }
    }
    
    /// Получение всех подписчиков пользователя.
    private func getUsersFollowingUser(with userID: User.Identifier, complition: @escaping ([User]?) -> Void) {
        
        blockView.show()
        
        DataProviders.shared.usersDataProvider.usersFollowingUser(with: userID, queue: .global(qos: .userInteractive)) {
            (usersFollowingUser) in
                        
            DispatchQueue.main.async {
                complition(usersFollowingUser)
                self.blockView.hide()
            }
        }
    }
    
    private func getUser(complition: @escaping (User?) -> Void) {
        
        guard let user = user else { return }
        
        DataProviders.shared.usersDataProvider.user(with: user.id, queue: .global(qos: .userInteractive)) {
            (user) in
            
            DispatchQueue.main.async {
                complition(user)
                self.blockView.hide()
            }
        }
    }
    
    // MARK: - СollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let reusableView = profileCollectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerProfile", for: indexPath) as! HeaderProfileCollectionView
            reusableView.frame = CGRect(x: 0 , y: 0, width: self.view.frame.width, height: 86)
            reusableView.delegate = self
            if let user = user {
                reusableView.configure(user: user, isCurrentUser: isCurrentUser)
            }
            return reusableView
        default: fatalError("Unexpected element kind")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photosOfUser.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = profileCollectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCollectionViewCell
        cell.configure(photosOfUser[indexPath.item])
        return cell
    }
}

extension ProfileViewController: UICollectionViewDelegateFlowLayout, HeaderProfileCollectionViewDelegate {
    
    // MARK: - Layout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = profileCollectionView.bounds.width / 3
        return CGSize(width: size, height: size)
    }
    
    // MARK: - Навигация
    func tapFollowersLabel() {
        
        guard let user = user else { return }
        
        getUsersFollowingUser(with: user.id) {
            (userList) in
            
            guard let userList = userList else { return }
            
            let followersVC = UserListViewController(userList: userList)
            followersVC.title = "Followers"
            self.navigationController?.pushViewController(followersVC, animated: true)
        }
    }
    
    func tapFollowingLabel() {
        
        guard let user = user else { return }
        
        getUsersFollowedByUser(with: user.id) {
            (userList) in
            
            guard let userList = userList else { return }
            
            let followingVC = UserListViewController(userList: userList)
            followingVC.title = "Following"
            self.navigationController?.pushViewController(followingVC, animated: true)
        }
    }
    
    // MARK: - Обработка подписки/отписки
    /// Подписка, либо отписка от пользователя.
    func followUnfollowUser() {
        
        guard let user = user else { return }
        
        // Подписка/отписка
        if user.currentUserFollowsThisUser {
            DataProviders.shared.usersDataProvider.unfollow(user.id, queue: .main) { _ in }
        } else {
            DataProviders.shared.usersDataProvider.follow(user.id, queue: .main) { _ in }
        }
        
        // Обновление данных об отображаемом пользователе
        getUser { (updatedUser) in
            
            guard let updatedUser = updatedUser else { return }
            
            self.user = updatedUser
            
            self.profileCollectionView.reloadData()
        }
    }
}
