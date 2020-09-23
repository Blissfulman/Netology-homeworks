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
    
    // По умолчанию вью отображает данные текущего пользователя
    var user: User!
    
    // MARK: - Методы жизненного цикла
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getCurrentUser()
        
//        sleep(3)
        
//        navigationItem.title = user.username
        
        photosCollectionView.register(UINib(nibName: "PhotoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "photoCell")
        photosCollectionView.register(UINib(nibName: "HeaderProfileCollectionView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerProfile")
        
        photosCollectionView.dataSource = self
        photosCollectionView.delegate = self
//        getPhotos(user)
    }
    
    // MARK: - Методы получения данных
    /// Возвращает текущего пользователя.
    private func getCurrentUser() {
//        var gettingUser: User
        let _ = DataProviders.shared.usersDataProvider.currentUser(queue: DispatchQueue.main) {
            (currentUser) in
            guard let currentUser = currentUser else {
                print("Current user was not recieved")
                return
            }
//            DispatchQueue.main.async {
//                gettingUser = currentUser
                self.user = currentUser
//            }
        }
//        return gettingUser
    }
    
    /// Получение фотографий постов пользователя
//    private func getPhotos(_ user: User?) {
//        if let filteredPosts = DataProviders.shared.postsDataProvider.findPosts(by: user.id) {
//            filteredPosts.forEach { photosOfUser.append($0.image) }
//        }
//    }
    
    // MARK: - СollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let reusableView = photosCollectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerProfile", for: indexPath) as! HeaderProfileCollectionView
            reusableView.frame = CGRect(x: 0 , y: 0, width: self.view.frame.width, height: 86)
            reusableView.delegate = self
            reusableView.configure(user: user)
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
//        guard let userList = DataProviders.shared.usersDataProvider.usersFollowedByUser(with: user.id) else { return }
//        let followersVC = UserListViewController(userList: userList)
//        followersVC.title = "Followers"
//        navigationController?.pushViewController(followersVC, animated: true)
    }
    
    func tapFollowingLabel() {
//        guard let userList = DataProviders.shared.usersDataProvider.usersFollowingUser(with: user.id) else { return }
//        let followingVC = UserListViewController(userList: userList)
//        followingVC.title = "Following"
//        navigationController?.pushViewController(followingVC, animated: true)
    }
}
