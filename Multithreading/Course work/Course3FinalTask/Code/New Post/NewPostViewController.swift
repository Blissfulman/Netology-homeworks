//
//  NewPostViewController.swift
//  Course3FinalTask
//
//  Created by User on 01.10.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import Foundation
import UIKit
import DataProvider

class NewPostViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: - Свойства
    private lazy var photosForNewPostCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: CGRect.zero,
                                              collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = .white
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    /// Массив новых фотографий.
    lazy var newPhotos = [UIImage]()
    
    /// Блокирующее вью, отображаемое во время одижания получения данных.
    let blockView = BlockView()
    
    // MARK: - Методы жизненного цикла
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let parentViewForBlockView = self.tabBarController?.view else { return }
        self.blockView.parentView = parentViewForBlockView
        blockView.setup()
        
        setupUI()
        setupConstraints()
        getNewPhotos()
        
        photosForNewPostCollectionView.register(UINib(nibName: "NewPostCollectionViewCell",
                                                      bundle: nil),
                                                forCellWithReuseIdentifier: "newPhotoCell")
        photosForNewPostCollectionView.dataSource = self
        photosForNewPostCollectionView.delegate = self
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        photosForNewPostCollectionView.reloadData()
//    }
    
    // MARK: - Layout
    private func setupUI() {
        view.addSubview(photosForNewPostCollectionView)
    }
    
    private func setupConstraints() {
        let constraints = [
            photosForNewPostCollectionView.topAnchor.constraint(equalTo: view.topAnchor),
            photosForNewPostCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            photosForNewPostCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            photosForNewPostCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: - Методы получения данных
    /// Получение текущего пользователя.
    func getNewPhotos() {
        newPhotos = DataProviders.shared.photoProvider.photos()
        
    }
    
    // MARK: - СollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return newPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = photosForNewPostCollectionView.dequeueReusableCell(withReuseIdentifier: "newPhotoCell", for: indexPath) as! NewPostCollectionViewCell
        cell.configure(newPhotos[indexPath.item])
        return cell
    }
}

extension NewPostViewController: UICollectionViewDelegateFlowLayout {

    // MARK: - Layout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = photosForNewPostCollectionView.bounds.width / 3
        return CGSize(width: size, height: size)
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
