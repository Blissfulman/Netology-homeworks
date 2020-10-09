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

class ProfileViewController: UIViewController {
    
    // MARK: - Свойства
    /// Пользователь, данные которого отображает вью.
    var user: User?
    
    /// Количество колонок в представлении фотографий.
    private let numberOfColumnsOfPhotos: CGFloat = 3
    
    /// Массив фотографий постов пользователя.
    private lazy var photosOfUser = [UIImage]()
    
    /// Логическое значение, указывающее, является ли отображаемый профиль, профилем текущего пользователя.
    private var isCurrentUser = true
    
    /// Блокирующее вью, отображаемое во время ожидания получения данных.
    private lazy var blockView = BlockView(parentView: self.tabBarController?.view ?? self.view)

    @IBOutlet weak var profileCollectionView: UICollectionView!
    
    // MARK: - Методы жизненного цикла
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileCollectionView.register(UINib(nibName: "ProfileCollectionViewCell",
                                             bundle: nil),
                                       forCellWithReuseIdentifier: "photoCell")
        profileCollectionView.register(UINib(nibName: "HeaderProfileCollectionView",
                                             bundle: nil),
                                       forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                       withReuseIdentifier: "headerProfile")
        
        profileCollectionView.dataSource = self
                
        // Если user != nil, значит это не стартовый экран профиля
        if let user = user {
            navigationItem.title = user.username
            getPhotos(user: user)
            
            // Проверка того, открывается ли это профиль текущего пользователя
            getCurrentUser { (currentUser) in
                guard let currentUser = currentUser else { return }
                
                if user.id != currentUser.id {
                    self.isCurrentUser = false
                }
            }
        } else {
            // Если user == nil, значит отображается начальный экран профиля текущего пользователя
            getCurrentUser { (currentUser) in
                guard let currentUser = currentUser else { return }
                
                self.user = currentUser
                self.navigationItem.title = currentUser.username
                self.getPhotos(user: currentUser)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        blockView.show()
        
        // Обновление данных об отображаемом пользователе
        getUser { (updatedUser) in

            guard let updatedUser = updatedUser else {
                let alert = ErrorAlertController(parentVC: self)
                alert.show()
                return
            }
            
            self.user = updatedUser
            self.profileCollectionView.reloadData()
            self.blockView.hide()
        }
    }
}

// MARK: - СollectionViewDataSource
extension ProfileViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let header = profileCollectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerProfile", for: indexPath) as! HeaderProfileCollectionView
            header.delegate = self
            if let user = user {
                header.configure(user: user, isCurrentUser: isCurrentUser)
            }
            return header
        default: fatalError("Unexpected element kind")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photosOfUser.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = profileCollectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! ProfileCollectionViewCell
        cell.configure(photosOfUser[indexPath.item])
        return cell
    }
}

// MARK: - CollectionViewLayout
extension ProfileViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = profileCollectionView.bounds.width / numberOfColumnsOfPhotos
        return CGSize(width: size, height: size)
    }
}

// MARK: - HeaderProfileCollectionViewDelegate
extension ProfileViewController: HeaderProfileCollectionViewDelegate {
    
    // MARK: - Навигация
    func tapFollowersLabel() {
        
        guard let user = user else { return }
        
        getUsersFollowingUser(with: user.id) {
            (userList) in
            
            guard let userList = userList else {
                let alert = ErrorAlertController(parentVC: self)
                alert.show()
                return
            }
            
            let followersVC = UserListViewController(userList: userList)
            followersVC.title = "Followers"
            self.navigationController?.pushViewController(followersVC, animated: true)
        }
    }
    
    func tapFollowingLabel() {
        
        guard let user = user else { return }
        
        getUsersFollowedByUser(with: user.id) {
            (userList) in
            
            guard let userList = userList else {
                let alert = ErrorAlertController(parentVC: self)
                alert.show()
                return
            }
            
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
            
            guard let updatedUser = updatedUser else {
                let alert = ErrorAlertController(parentVC: self)
                alert.show()
                return
            }
            
            self.user = updatedUser
            self.profileCollectionView.reloadData()
        }
    }
}

// MARK: - Методы получения данных
extension ProfileViewController {
    
    /// Получение текущего пользователя.
    private func getCurrentUser(completion: @escaping (_ currentUser: User?) -> Void) {
                
        DataProviders.shared.usersDataProvider.currentUser(queue: .global(qos: .userInteractive)) {
            (currentUser) in
            
            DispatchQueue.main.async {
                completion(currentUser)
            }
        }
    }
    
    /// Получение всех публикаций пользователя с переданным ID.
    private func getPhotos(user: User) {
                                
        DataProviders.shared.postsDataProvider.findPosts(by: user.id, queue: .global(qos: .userInteractive)) {
            (userPosts) in
                        
            DispatchQueue.main.async {

                guard let userPosts = userPosts else {
                    let alert = ErrorAlertController(parentVC: self)
                    alert.show()
                    return
                }
                
                userPosts.forEach { self.photosOfUser.append($0.image) }
                self.profileCollectionView.reloadData()
                self.blockView.hide()
            }
        }
    }
    
    /// Получение всех подписок пользователя.
    private func getUsersFollowedByUser(with userID: User.Identifier, completion: @escaping ([User]?) -> Void) {
        
        blockView.show()
        
        DataProviders.shared.usersDataProvider.usersFollowedByUser(with: userID, queue: .global(qos: .userInteractive)) {
            (usersFollowedByUser) in
                        
            DispatchQueue.main.async {
                completion(usersFollowedByUser)
                self.blockView.hide()
            }
        }
    }
    
    /// Получение всех подписчиков пользователя.
    private func getUsersFollowingUser(with userID: User.Identifier, completion: @escaping ([User]?) -> Void) {
        
        blockView.show()
        
        DataProviders.shared.usersDataProvider.usersFollowingUser(with: userID, queue: .global(qos: .userInteractive)) {
            (usersFollowingUser) in
                        
            DispatchQueue.main.async {
                completion(usersFollowingUser)
                self.blockView.hide()
            }
        }
    }
    
    private func getUser(completion: @escaping (User?) -> Void) {
        
        guard let user = user else { return }
        
        DataProviders.shared.usersDataProvider.user(with: user.id, queue: .global(qos: .userInteractive)) {
            (user) in
            
            DispatchQueue.main.async {
                completion(user)
            }
        }
    }
}
