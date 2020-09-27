//
//  FeedTableViewCell.swift
//  Course2FinalTask
//
//  Created by User on 04.08.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit
import DataProvider

protocol FeedTableViewCellDelegate: AnyObject {
    func tapAuthorOfPost(user: User)
    func tapLikesCountLabel(userList: [User])
    func updateFeedData()
    func showBlockView()
    func hideBlockView()
}

class FeedTableViewCell: UITableViewCell {

    // MARK: - Свойства
    private var cellPostID: Post.Identifier = ""
    weak var delegate: FeedTableViewCellDelegate?
    
//    typealias MyThread = DispatchQueue.global(qos: .userInteractive)
    
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var authorUsernameLabel: UILabel!
    @IBOutlet weak var createdTimeLabel: UILabel!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var bigLikeImage: UIImageView!
    @IBOutlet weak var likesCountLabel: UILabel!
    @IBOutlet weak var likeImage: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    // MARK: - Методы жизненного цикла
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setGestureRecognizers()
    }
    
    // MARK: - Методы получения данных
    /// Получение публикации с переданным ID.
    private func getPost(postID: Post.Identifier, complition: @escaping (Post?) -> Void) {
        DataProviders.shared.postsDataProvider.post(with: postID, queue: .global(qos: .userInteractive)) {
            (post) in
            DispatchQueue.main.async {
                complition(post)
            }
        }
    }
    
    /// Получение пользователя с переданным ID.
    private func getUser(userID: User.Identifier, complition: @escaping (User?) -> Void) {
        DataProviders.shared.usersDataProvider.user(with: userID, queue: .global(qos: .userInteractive)) {
            (user) in
            DispatchQueue.main.async {
                complition(user)
            }
        }
    }
    
    /// Получение пользователей, поставивших лайк на публикацию.
    private func getUsersLikedPost(postID: Post.Identifier, complition: @escaping ([User]?) -> Void) {
        DataProviders.shared.postsDataProvider.usersLikedPost(with: postID, queue: .global(qos: .userInteractive)) {
            (usersLikedPost) in
            DispatchQueue.main.async {
                complition(usersLikedPost)
            }
        }
    }
    
    // MARK: - Распознователи жестов
    private func setGestureRecognizers() {
        
        // Жест двойного тапа по картинке поста
        let postImageGR = UITapGestureRecognizer(target: self, action: #selector(tapPostImage(recognizer:)))
        postImageGR.numberOfTapsRequired = 2
        postImage.isUserInteractionEnabled = true
        postImage.addGestureRecognizer(postImageGR)
        
        // Жест тапа по автору поста (по аватарке)
        let authorAvatarGR = UITapGestureRecognizer(target: self, action: #selector(tapAuthorOfPost(recognizer:)))
        avatarImage.isUserInteractionEnabled = true
        avatarImage.addGestureRecognizer(authorAvatarGR)
        
        // Жест тапа по автору поста (по username)
        let authorUsernameGR = UITapGestureRecognizer(target: self, action: #selector(tapAuthorOfPost(recognizer:)))
        authorUsernameLabel.isUserInteractionEnabled = true
        authorUsernameLabel.addGestureRecognizer(authorUsernameGR)
        
        // Жест тапа по количеству лайков поста
        let likesCountGR = UITapGestureRecognizer(target: self, action: #selector(tapLikesCountLabel(recognizer:)))
        likesCountLabel.isUserInteractionEnabled = true
        likesCountLabel.addGestureRecognizer(likesCountGR)
        
        // Жест тапа по сердечку под постом
        let likeImageGR = UITapGestureRecognizer(target: self, action: #selector(tapLikeImage(recognizer:)))
        likeImage.isUserInteractionEnabled = true
        likeImage.addGestureRecognizer(likeImageGR)
    }
    
    // MARK: - Настройка элементов ячейки
    func fillingCell(_ post: Post) {
                
        // Запись в переменную ID поста ячейки
        cellPostID = post.id
        
        // Заполнение всех элементов ячейки данными
        avatarImage.image = post.authorAvatar
        authorUsernameLabel.text = post.authorUsername
        createdTimeLabel.text = setDateAndTime(post.createdTime)
        postImage.image = post.image
        likesCountLabel.text = setCountLikesForPost(post)
        setLikeImageColor(post)
        descriptionLabel.text = post.description
    }
    
    private func setDateAndTime(_ date: Date) -> String {
        let dateFormat = DateFormatter()
        dateFormat.dateStyle = .medium
        dateFormat.timeStyle = .medium
        dateFormat.doesRelativeDateFormatting = true
        return dateFormat.string(from: date as Date)
    }
    
    private func setCountLikesForPost(_ post: Post) -> String {
        return "Likes: " + String(post.likedByCount)
    }
    
    private func setLikeImageColor(_ post: Post) {
        likeImage.tintColor = post.currentUserLikesThisPost ? .systemBlue : .lightGray
    }
    
    // MARK: - Действия на жесты
    /// Двойной тап по картинке поста.
    @IBAction func tapPostImage(recognizer: UITapGestureRecognizer) {
        
        getPost(postID: cellPostID) {
            (post) in
            
            guard let post = post else { return }
            
            // Проверка отсутствия у поста лайка текущего пользователя
            guard !post.currentUserLikesThisPost else { return }
            
            // Анимация большого сердца
            let likeAnimation = CAKeyframeAnimation(keyPath: "opacity")
            likeAnimation.values = [0, 1, 1, 0]
            likeAnimation.keyTimes = [0, 0.1, 0.3, 0.6]
            likeAnimation.timingFunctions = [.init(name: .linear), .init(name: .linear), .init(name: .easeOut)]
            likeAnimation.duration = 0.6
            self.bigLikeImage.layer.add(likeAnimation, forKey: nil)
            
            // Обработка лайка
            self.likeUnlikePost()
        }
    }
    
    /// Тап по автору поста.
    @IBAction func tapAuthorOfPost(recognizer: UIGestureRecognizer) {
        
        delegate?.showBlockView()
        
        getPost(postID: cellPostID) {
            (post) in
            
            guard let post = post else { return }
            
            self.getUser(userID: post.author) {
                (user) in
                
                guard let user = user else { return }
                
                self.delegate?.tapAuthorOfPost(user: user)
                
                self.delegate?.hideBlockView()
            }
        }
    }
    
    /// Тап по количеству лайков поста.
    @IBAction func tapLikesCountLabel(recognizer: UIGestureRecognizer) {
        
        delegate?.showBlockView()
        
        // Создание массива пользователей, лайкнувших пост
        getUsersLikedPost(postID: cellPostID) {
            (userList) in
            
            guard let userList = userList else { return }
            
            // Передача массива пользователей для дальнейшего перехода на экран лайкнувших пост пользователей
            self.delegate?.tapLikesCountLabel(userList: userList)
            
            self.delegate?.hideBlockView()
        }
    }
    
    /// Тап  по сердечку под постом.
    @IBAction func tapLikeImage(recognizer: UIGestureRecognizer) {
        likeUnlikePost()
    }
    
    // MARK: - Обработка лайков
    /// Лайк, либо отмена лайка поста.
    private func likeUnlikePost() {
        
        getPost(postID: cellPostID) {
            (post) in
            
            guard let post = post else { return }
            
            // Лайк/анлайк поста
            if post.currentUserLikesThisPost {
                DataProviders.shared.postsDataProvider.unlikePost(with: self.cellPostID, queue: .main) { _ in }
            } else {
                DataProviders.shared.postsDataProvider.likePost(with: self.cellPostID, queue: .main) { _ in }
            }
            
            // Получение обновлённого поста
            self.getPost(postID: self.cellPostID) {
                (updatedPost) in
                
                guard let updatedPost = updatedPost else { return }
                
                // Обновление отображения количества лайков у поста
                self.likesCountLabel.text = self.setCountLikesForPost(updatedPost)
                
                // Смена цвета сердечка
                self.setLikeImageColor(updatedPost)
                
                // Обновление данных в массиве постов
                self.delegate?.updateFeedData()
            }
        }
    }
}
