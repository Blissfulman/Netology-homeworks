//
//  FiltersViewController.swift
//  Course3FinalTask
//
//  Created by User on 04.10.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

class FiltersViewController: UIViewController {

    // MARK: - Свойства
    /// Блокирующее вью, отображаемое во время ожидания получения данных.
    private lazy var blockView = BlockView(parentView: self.tabBarController?.view ?? self.view)

    /// Выбранное изображение, отображаемое на всю ширину экрана.
    private lazy var bigImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    /// Коллекция выбора фильтров с примерами их применения для обработки большого изображения.
    @IBOutlet weak var filtersCollectionView: UICollectionView!
    
    // MARK: - Инициализаторы
    convenience init(selectedImage: UIImage) {
        self.init()
        self.bigImage.image = selectedImage
    }
    
    // MARK: - Методы жизненного цикла
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(bigImage)
        setupLayout()
        filtersCollectionView.backgroundColor = .yellow
        filtersCollectionView.dataSource = self
        filtersCollectionView.delegate = self
        
        filtersCollectionView.register(UINib(nibName: "FiltersCollectionViewCell",
                                             bundle: nil),
                                       forCellWithReuseIdentifier: "filterCell")
    }
    
    // MARK: - Layout
    private func setupLayout() {
        let constraints = [
            bigImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            bigImage.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            bigImage.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            bigImage.heightAnchor.constraint(equalTo: bigImage.widthAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
}

extension FiltersViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: - CollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = filtersCollectionView.dequeueReusableCell(withReuseIdentifier: "filterCell", for: indexPath) as! FiltersCollectionViewCell
        cell.backgroundColor = .orange
//        cell.configure(filters[indexPath.item])
        return cell
    }
}

extension FiltersViewController: UICollectionViewDelegateFlowLayout {
    
    // MARK: - CollectionViewLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 120, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
