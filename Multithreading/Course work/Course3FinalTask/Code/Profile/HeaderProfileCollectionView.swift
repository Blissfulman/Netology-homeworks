//
//  HeaderProfileCollectionView.swift
//  Course2FinalTask
//
//  Created by User on 08.08.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import Foundation
import UIKit
import DataProvider

protocol HeaderProfileCollectionViewDelegate: UIViewController {
    func tapFollowersLabel()
    func tapFollowingLabel()
    func followUnfollowUser()
}

class HeaderProfileCollectionView: UICollectionReusableView {
    
    // MARK: - Свойства
    weak var delegate: HeaderProfileCollectionViewDelegate?
    
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    
    // MARK: - Методы жизненного цикла
    override func awakeFromNib() {
        super.awakeFromNib()
        
        followButton.layer.cornerRadius = 5
        setGestureRecognizers()
        followButton.sizeToFit()
    }
    
    // MARK: - Настройка элементов ячейки
    func configure(user: User, isCurrentUser: Bool) {
        avatarImage.image = user.avatar
        avatarImage.layer.cornerRadius = CGFloat(avatarImage.bounds.width / 2)
        fullNameLabel.text = user.fullName
        followersLabel.text = "Followers: " + String(user.followedByCount)
        followingLabel.text = "Following: " + String(user.followsCount)
        
        // Если это не профиль текущего пользователя, то устанавливается кнопка подписки/отписки
        if !isCurrentUser {
            setupFollowButton(user: user)
        }
    }
    
    private func setupFollowButton(user: User) {
    
        if user.currentUserFollowsThisUser {
            followButton.setTitle("Unfollow", for: .normal)
        } else {
            followButton.setTitle("Follow", for: .normal)
        }
        followButton.isHidden = false
    }
    
    // MARK: - Распознователи жестов
    private func setGestureRecognizers() {
        
        // Жест тапа по подписчикам
        let followersGR = UITapGestureRecognizer(target: self, action: #selector(tapFollowersLabel(recognizer:)))
        followersLabel.isUserInteractionEnabled = true
        followersLabel.addGestureRecognizer(followersGR)
        
        // Жест тапа по подпискам
        let followingGR = UITapGestureRecognizer(target: self, action: #selector(tapFollowingLabel(recognizer:)))
        followingLabel.isUserInteractionEnabled = true
        followingLabel.addGestureRecognizer(followingGR)
    }
    
    // MARK: - Actions
    @IBAction func tapFollowersLabel(recognizer: UIGestureRecognizer) {
        delegate?.tapFollowersLabel()
    }
    
    @IBAction func tapFollowingLabel(recognizer: UIGestureRecognizer) {
        delegate?.tapFollowingLabel()
    }
    
    @IBAction func followButtonClick(_ sender: UIButton) {
        delegate?.followUnfollowUser()
    }
}
