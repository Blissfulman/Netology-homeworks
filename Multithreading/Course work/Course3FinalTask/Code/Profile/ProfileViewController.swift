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
    
    @IBOutlet weak var photosCollectionView: UICollectionView!
    
    // MARK: - Свойства
    /// Массив фотографий постов пользователя
    lazy var photosOfUser = [UIImage]()
    
    /// Пользователь, данные которого отображает вью
    var user: User?
    
    /// Блокирующее вью, отображаемое во время одижания получения данных
    let blockView = BlockView()
    
    // MARK: - Методы жизненного цикла
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let parentViewForBlockView = self.tabBarController?.view else { return }
        self.blockView.parentView = parentViewForBlockView
        blockView.setup()
        
        photosCollectionView.register(UINib(nibName: "PhotoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "photoCell")
        photosCollectionView.register(UINib(nibName: "HeaderProfileCollectionView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerProfile")
        
        photosCollectionView.dataSource = self
        photosCollectionView.delegate = self
        
        if let user = user {
            navigationItem.title = user.username
            getPhotos(user: user)
            photosCollectionView.reloadData()
        } else {
            getCurrentUser()
        }
    }
    
    // MARK: - Методы получения данных
    /// Получение текущего пользователя.
    private func getCurrentUser() {
        
        blockView.show()
        
        DataProviders.shared.usersDataProvider.currentUser(queue: DispatchQueue.global(qos: .userInitiated)) {
            (currentUser) in
            
            guard let currentUser = currentUser else { return }
            
            DispatchQueue.main.async {
                self.user = currentUser
                self.navigationItem.title = self.user?.username
                self.getPhotos(user: currentUser)
            }
        }
    }
    
    /// Получение всех публикаций пользователя с переданным ID.
    private func getPhotos(user: User) {
        
        blockView.show()
        
        DataProviders.shared.postsDataProvider.findPosts(by: user.id, queue: DispatchQueue.global(qos: .userInitiated)) {
            (userPosts) in
            if let userPosts = userPosts {
                userPosts.forEach { self.photosOfUser.append($0.image) }
                DispatchQueue.main.async {
                    self.photosCollectionView.reloadData()
                    self.blockView.hide()
                }
            }
        }
    }
    
    /// Получение всех подписок пользователя.
    private func getUsersFollowedByUser(with userID: User.Identifier, closure: @escaping ([User]?) -> Void) {
        
        blockView.show()
        
        DataProviders.shared.usersDataProvider.usersFollowedByUser(with: userID, queue: DispatchQueue.global(qos: .userInteractive)) {
            (usersFollowedByUser) in
                        
            DispatchQueue.main.async {
                closure(usersFollowedByUser)
                self.blockView.hide()
            }
        }
    }
    
    /// Получение всех подписчиков пользователя.
    private func getUsersFollowingUser(with userID: User.Identifier, closure: @escaping ([User]?) -> Void) {
        
        blockView.show()
        
        DataProviders.shared.usersDataProvider.usersFollowingUser(with: userID, queue: DispatchQueue.global(qos: .userInteractive)) {
            (usersFollowingUser) in
                        
            DispatchQueue.main.async {
                closure(usersFollowingUser)
                self.blockView.hide()
            }
        }
    }
    
    // MARK: - СollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let reusableView = photosCollectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerProfile", for: indexPath) as! HeaderProfileCollectionView
            reusableView.frame = CGRect(x: 0 , y: 0, width: self.view.frame.width, height: 86)
            reusableView.delegate = self
            if let user = user {
                reusableView.configure(user: user)
            }
            return reusableView
        default: fatalError("Unexpected element kind")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photosOfUser.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = photosCollectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCollectionViewCell
        cell.configure(photosOfUser[indexPath.item])
        return cell
    }
}

extension ProfileViewController: UICollectionViewDelegateFlowLayout, HeaderProfileCollectionViewDelegate {
    
    // MARK: - Layout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = photosCollectionView.bounds.width / 3
        return CGSize(width: size, height: size)
    }
    
    // MARK: - Навигация
    func tapFollowersLabel() {
        
        guard let user = user else { return }
        
        getUsersFollowedByUser(with: user.id) {
            (userList) in
            
            guard let userList = userList else { return }
            
            let followersVC = UserListViewController(userList: userList)
            followersVC.title = "Followers"
            self.navigationController?.pushViewController(followersVC, animated: true)
        }
    }
    
    func tapFollowingLabel() {
        
        guard let user = user else { return }
        
        getUsersFollowingUser(with: user.id) {
            (userList) in
            
            guard let userList = userList else { return }
            
            let followingVC = UserListViewController(userList: userList)
            followingVC.title = "Following"
            self.navigationController?.pushViewController(followingVC, animated: true)
        }
    }
}
