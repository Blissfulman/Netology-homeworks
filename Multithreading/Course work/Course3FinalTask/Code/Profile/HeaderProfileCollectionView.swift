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

protocol HeaderProfileCollectionViewDelegate: AnyObject {
    func tapFollowersLabel()
    func tapFollowingLabel()
}

class HeaderProfileCollectionView: UICollectionReusableView {
    
    // MARK: - Свойства
    weak var delegate: HeaderProfileCollectionViewDelegate?
    
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    
    // MARK: - Методы жизненного цикла
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setGestureRecognizers()
    }
    
    // MARK: - Настройка элементов ячейки
    func configure(user: User) {
        avatarImage.image = user.avatar
        avatarImage.layer.cornerRadius = CGFloat(avatarImage.bounds.width / 2)
        fullNameLabel.text = user.fullName
        followersLabel.text = "Followers: " + String(user.followsCount)
        followingLabel.text = "Following: " + String(user.followedByCount)
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
    
    // MARK: - Действия на жесты
    @IBAction func tapFollowersLabel(recognizer: UIGestureRecognizer) {
        delegate?.tapFollowersLabel()
    }
    
    @IBAction func tapFollowingLabel(recognizer: UIGestureRecognizer) {
        delegate?.tapFollowingLabel()
    }
}
