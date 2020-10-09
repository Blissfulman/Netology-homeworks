//
//  ShareViewController.swift
//  Course3FinalTask
//
//  Created by User on 08.10.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit
import DataProvider

class ShareViewController: UIViewController {
    
    // MARK: - Свойства
    /// Переданное изображение для публикации.
    private lazy var transferredImage = UIImage()
    
    @IBOutlet weak var shareImage: UIImageView!
    @IBOutlet weak var descriptionTextField: UITextField!
    
    // MARK: - Инициализаторы
    convenience init(shareImage: UIImage) {
        self.init()
        transferredImage = shareImage
    }
    
    // MARK: - Методы жизненного цикла
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    // MARK: - Setup UI
    func setupUI() {
        shareImage.image = transferredImage
        
        let shareButton = UIBarButtonItem(title: "Share",
                                         style: .plain,
                                         target: self,
                                         action: #selector(pressedShareButton))
        navigationItem.rightBarButtonItem = shareButton
    }
    
    // MARK: - Actions
    @objc func pressedShareButton() {
        
        guard let description = descriptionTextField.text else { return }
        
        // Публикация нового поста
        DataProviders.shared.postsDataProvider
            .newPost(with: transferredImage,
                     description: description,
                     queue: .main) { _ in
                        
                        // Получение корневого вью элемента таб бара "Feed"
                        guard let navControllerFeed = self.tabBarController?.viewControllers?[0] as? UINavigationController else { return }
                        navControllerFeed.popToRootViewController(animated: false)
                        
                        // Скроллинг в верхнее положение ленты
                        guard let feedVC = navControllerFeed.viewControllers[0] as? FeedViewController else { return }
                        feedVC.feedTableView.setContentOffset(.zero, animated: false)
                        
                        // Переход на ленту
                        self.tabBarController?.selectedIndex = 0
                                                
                        // Переход на корневое вью элемента таб бара "New post"
                        self.navigationController?.popToRootViewController(animated: false)
        }
    }
}