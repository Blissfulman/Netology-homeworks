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

    /// Изображение, отображаемое на всю ширину экрана.
    private lazy var bigImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    /// Исходное большое изображение.
    private lazy var originalBigImage = UIImage()
    
    /// Миниатюра выбранного изображения.
    private var thumbnailImage = UIImage()
    
    /// Массив для отфильтрованных миниатюр изображения
    private var filteredThumbnails = [UIImage]()
    
    /// Массив имён фильтров для обработки изображения.
    private let filters = ["CISpotLight", "CIPixellate", "CIUnsharpMask",
        "CISepiaTone", "CICircularScreen", "CICMYKHalftone", "CIVignetteEffect"]
    
    // Константы размеров элементов коллекции фильтров.
    private let widthForItem: CGFloat = 130
    private let heightForItem: CGFloat = 79
    private let minimumLineSpacing: CGFloat = 16
    private let minimumInteritemSpacing: CGFloat = 0
    
    /// Коллекция выбора фильтров с примерами их применения для обработки большого изображения.
    @IBOutlet weak var filtersCollectionView: UICollectionView!
    
    // MARK: - Инициализаторы
    convenience init(selectedImage: UIImage, thumbnail: UIImage) {
        self.init()
        bigImage.image = selectedImage
        originalBigImage = selectedImage
        thumbnailImage = thumbnail
        filteredThumbnails = .init(repeating: thumbnailImage,
                                   count: filters.count)
    }
    
    // MARK: - Методы жизненного цикла
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupLayout()

        filtersCollectionView.dataSource = self
        filtersCollectionView.delegate = self
        filtersCollectionView.register(UINib(nibName: "FiltersCollectionViewCell",
                                             bundle: nil),
                                       forCellWithReuseIdentifier: "filterCell")
        filteringThumbnailImages()
    }
    
    // MARK: - Setup UI
    func setupUI() {
        let nextButton = UIBarButtonItem(title: "Next",
                                         style: .plain,
                                         target: self,
                                         action: #selector(pressedNextButton))
        navigationItem.rightBarButtonItem = nextButton
        
        view.addSubview(bigImage)
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
    
    // MARK: - Применение фильтров к миниатюрам
    func filteringThumbnailImages() {
        
        let queue = OperationQueue()
        for item in 0..<filters.count {
            let filterOperation = FilterImageOperation(inputImage: thumbnailImage,
                                                       filter: filters[item])
            filterOperation.completionBlock = {
                DispatchQueue.main.async {
                    guard let outputImage = filterOperation.outputImage else { return }
                    self.filteredThumbnails[item] = outputImage
                    self.filtersCollectionView.reloadItems(at: [.init(item: item, section: 0)])
                }
            }
            queue.addOperation(filterOperation)
        }
    }
    
    // MARK: - Actions
    @objc func pressedNextButton() {
        guard let shareImage = bigImage.image else { return }
        let shareVC = ShareViewController(shareImage: shareImage)
        navigationController?.pushViewController(shareVC, animated: true)
    }
}

extension FiltersViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: - CollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        filters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = filtersCollectionView.dequeueReusableCell(withReuseIdentifier: "filterCell", for: indexPath) as! FiltersCollectionViewCell
        cell.configure(photo: filteredThumbnails[indexPath.item],
                       filterName: filters[indexPath.item])
        return cell
    }
    
    // MARK: - CollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // Применение выбранного фильтра к большому изображению
        blockView.show()
        let queue = OperationQueue()
        let filterOperation = FilterImageOperation(inputImage: originalBigImage,
                                                   filter: filters[indexPath.item])
        filterOperation.completionBlock = {
            DispatchQueue.main.async {
                guard let outputImage = filterOperation.outputImage else { return }
                self.bigImage.image = outputImage
                self.blockView.hide()
            }
        }
        queue.addOperation(filterOperation)
    }
}

// MARK: - CollectionViewLayout
extension FiltersViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: widthForItem, height: heightForItem)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return minimumLineSpacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return minimumInteritemSpacing
    }
}
