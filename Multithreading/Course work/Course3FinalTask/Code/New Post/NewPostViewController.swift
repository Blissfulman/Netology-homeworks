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

class NewPostViewController: UIViewController {
    
    // MARK: - Свойства
    /// Количество колонок в представлении фотографий.
    private let numberOfColumnsOfPhotos: CGFloat = 3
    
    /// Массив новых фотографий.
    private lazy var newPhotos = [UIImage]()
    
    /// Коллекция изображений для использования в новых публикациях.
    private lazy var photosForNewPostCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: CGRect.zero,
                                              collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    // MARK: - Методы жизненного цикла
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(photosForNewPostCollectionView)
        setupLayout()
        getNewPhotos()
        
        photosForNewPostCollectionView.register(UINib(nibName: "NewPostCollectionViewCell",
                                                      bundle: nil),
                                                forCellWithReuseIdentifier: "newPhotoCell")
    }
    
    // MARK: - Layout
    private func setupLayout() {
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
}

extension NewPostViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: - СollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return newPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = photosForNewPostCollectionView.dequeueReusableCell(withReuseIdentifier: "newPhotoCell", for: indexPath) as! NewPostCollectionViewCell
        cell.configure(newPhotos[indexPath.item])
        return cell
    }
    
    // MARK: - СollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let filtersVC = FiltersViewController(selectedImage: newPhotos[indexPath.item])
        filtersVC.title = "Filters"
        navigationController?.pushViewController(filtersVC, animated: true)
    }
}

extension NewPostViewController: UICollectionViewDelegateFlowLayout {

    // MARK: - Layout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = photosForNewPostCollectionView.bounds.width / numberOfColumnsOfPhotos
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
