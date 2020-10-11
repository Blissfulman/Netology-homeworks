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
        
    /// Массив фотографий постов пользователя.
    private lazy var photosOfUser = [UIImage]()
    
    /// Логическое значение, указывающее, является ли отображаемый профиль, профилем текущего пользователя.
    private var isCurrentUser: Bool?
    
    /// Блокирующее вью, отображаемое во время ожидания получения данных.
    private lazy var blockView = BlockView(parentView: self.tabBarController?.view ?? self.view)

    /// Количество колонок в представлении фотографий.
    private let numberOfColumnsOfPhotos: CGFloat = 3
    
    /// Очередь для выстраивания запросов данных у провайдера.
    private let queue = DispatchQueue(label: "Queue",
                                      qos: .userInteractive)
    /// Семафор для установки порядка запросов к провайдеру.
    private let semaphore = DispatchSemaphore(value: 1)
    
    /// Коллекция, отображающая информацию о пользователе.
    @IBOutlet weak var profileCollectionView: UICollectionView!
    
    // MARK: - Методы жизненного цикла
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileCollectionView.register(ProfileCollectionViewCell.nib(),
                                       forCellWithReuseIdentifier: ProfileCollectionViewCell.identifier)
        profileCollectionView.register(HeaderProfileCollectionView.nib(),
                                       forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                       withReuseIdentifier: HeaderProfileCollectionView.identifier)

        profileCollectionView.dataSource = self
                
        queue.async {
            
            self.semaphore.wait()

            self.getCurrentUser { [weak self] (currentUser) in
                
                guard let `self` = self else { return }
                
                guard let currentUser = currentUser else {
                    let alert = ErrorAlertController(parentVC: self)
                    alert.show()
                    self.semaphore.signal()
                    return
                }

                // Проверка того, открывается ли профиль текущего пользователя
                if let userID = self.user?.id, userID != currentUser.id {
                    self.isCurrentUser = false
                } else {
                    self.isCurrentUser = true
                    self.user = currentUser
                }

                self.navigationItem.title = self.user?.username
                self.semaphore.signal()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        blockView.show()
        
        queue.async {
            
            self.semaphore.wait()
            
            // Обновление данных о пользователе
            self.getUser { [weak self] (user) in
                
                guard let `self` = self else { return }
                                
                guard let user = user else {
                    let alert = ErrorAlertController(parentVC: self)
                    alert.show()
                    self.semaphore.signal()
                    return
                }
                
                self.user = user
                self.profileCollectionView.reloadData()
                self.semaphore.signal()
                
                // Обновление данных об изображениях постов пользователя
                self.getPhotos(user: user)
            }
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
            if let user = user, let isCurrentUser = isCurrentUser {
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
            [weak self] (userList) in
            
            guard let `self` = self else { return }
            
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
            [weak self] (userList) in
            
            guard let `self` = self else { return }
            
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
        getUser { [weak self] (updatedUser) in
            
            guard let `self` = self else { return }
            
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

        DataProviders.shared.usersDataProvider.currentUser(queue: .main) {
            (currentUser) in

            completion(currentUser)
        }
    }
    
    /// Получение всех публикаций пользователя с переданным ID.
    private func getPhotos(user: User) {
                
        DataProviders.shared.postsDataProvider.findPosts(by: user.id, queue: .global(qos: .userInteractive)) {
            [weak self] (userPosts) in
            
            guard let `self` = self else { return }
            
            DispatchQueue.main.async {
                
                defer {
                    self.blockView.hide()
                }

                guard let userPosts = userPosts else {
                    let alert = ErrorAlertController(parentVC: self)
                    alert.show()
                    return
                }
                
                self.photosOfUser = []
                userPosts.forEach { self.photosOfUser.append($0.image) }
                
                self.profileCollectionView.reloadData()
            }
        }
    }
    
    /// Получение всех подписок пользователя.
    private func getUsersFollowedByUser(with userID: User.Identifier, completion: @escaping ([User]?) -> Void) {
        
        blockView.show()
        
        DataProviders.shared.usersDataProvider.usersFollowedByUser(with: userID, queue: .global(qos: .userInteractive)) {
            [weak self] (usersFollowedByUser) in
            
            guard let `self` = self else { return }
            
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
            [weak self] (usersFollowingUser) in
            
            guard let `self` = self else { return }
                        
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
