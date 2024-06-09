//
//  MemeGeneratorViewController.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/5/12.
//

import UIKit
import Lottie

class MemeGeneratorViewController: UIViewController {
    
    var viewModel = MemeGeneratorViewModel()
    var originalPetImageView: UIImageView!
    var layerEditingContainer: UIView!
    var filterCollectionView: UICollectionView!
    var animationView: LottieAnimationView!
    var imagePickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationTitle(.MemeGenerator)
        setupUI()
        setupNavigationBar()
        setupLayerEditingContainer()
        setupFilterCollectionView()
        
        // 設定 VM 的 callback 方法
        viewModel.onImageUpdated = { [weak self] image in
            self?.originalPetImageView.image = image
        }
        
        viewModel.onFilterPreviewsUpdated = { [weak self] in
            self?.filterCollectionView.reloadData()
        }
        
        // 預設圖片
        originalPetImageView.image = UIImage(named: "dogInPark")
        viewModel.updateImage(originalPetImageView.image!)
        
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        view.backgroundColor = .white
    }
    
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "儲存", style: .done, target: self, action: #selector(savePetMeme))
    }
    
    private func setupLayerEditingContainer() {
        layerEditingContainer = UIView()
        
        originalPetImageView = UIImageView()
        originalPetImageView.contentMode = .scaleAspectFill
        originalPetImageView.isUserInteractionEnabled = true
        originalPetImageView.clipsToBounds = true
        
        // 添加點擊手勢識別器
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
        originalPetImageView.addGestureRecognizer(tapGestureRecognizer)
        
        layerEditingContainer.translatesAutoresizingMaskIntoConstraints = false
        originalPetImageView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(layerEditingContainer)
        layerEditingContainer.addSubview(originalPetImageView)
        
        NSLayoutConstraint.activate([
            layerEditingContainer.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            layerEditingContainer.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            layerEditingContainer.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            layerEditingContainer.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.5),
            
            originalPetImageView.leadingAnchor.constraint(equalTo: layerEditingContainer.leadingAnchor),
            originalPetImageView.trailingAnchor.constraint(equalTo: layerEditingContainer.trailingAnchor),
            originalPetImageView.topAnchor.constraint(equalTo: layerEditingContainer.topAnchor),
            originalPetImageView.bottomAnchor.constraint(equalTo: layerEditingContainer.bottomAnchor)
        ])
        
    }
    
    private func setupFilterCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let itemsPerRow: CGFloat = 4
        let spacing: CGFloat = 10
        let totalSpacing = (itemsPerRow - 1) * spacing
        let itemWidth = (view.frame.width - totalSpacing) / itemsPerRow
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing
        
        filterCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        filterCollectionView.delegate = self
        filterCollectionView.dataSource = self
        filterCollectionView.register(FilterCell.self, forCellWithReuseIdentifier: "FilterCell")
        filterCollectionView.backgroundColor = .clear
        filterCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(filterCollectionView)
        
        NSLayoutConstraint.activate([
            filterCollectionView.topAnchor.constraint(equalTo: layerEditingContainer.bottomAnchor),
            filterCollectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            filterCollectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            filterCollectionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    // MARK: - Action
    
    @objc func savePetMeme(){
        if let finalMemeImage = viewModel.saveMeme(from: layerEditingContainer) {
            UIImageWriteToSavedPhotosAlbum(finalMemeImage, nil, nil, nil)
            
            let alert = UIAlertController(title: "儲存成功", message: "已儲存照片至相簿", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "確定", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func imageTapped(_ sender: UITapGestureRecognizer) {
        presentImagePicker()
    }
    
    private func presentImagePicker() {
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.sourceType = .photoLibrary
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @objc func panOverlayView(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: originalPetImageView)
        // gesture.view 就是 overlayView
        if let view = gesture.view {
            view.center = CGPoint(x: view.center.x + translation.x, y: view.center.y + translation.y)
        }
        gesture.setTranslation(.zero, in: originalPetImageView)
    }
    
    @objc func pinchOverlayView(_ gesture: UIPinchGestureRecognizer) {
        if let view = gesture.view {
            view.transform = view.transform.scaledBy(x: gesture.scale, y: gesture.scale)
            gesture.scale = 1.0
        }
    }
    
    @objc func tapOverlayView(_ gesture: UITapGestureRecognizer) {
        if let overlayView = gesture.view {
            let alert = UIAlertController(title: "確定要刪除嗎？", message: nil, preferredStyle: .alert)
            
            let deleteAction = UIAlertAction(title: "確定", style: .destructive) { _ in
                overlayView.removeFromSuperview()
            }
            
            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            
            alert.addAction(deleteAction)
            alert.addAction(cancelAction)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
}

// MARK: - ImagePicker Delegate

extension MemeGeneratorViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[.editedImage] as? UIImage {
            // 通知 VM 更新圖片
            viewModel.updateImage(editedImage)
        } else if let originalImage = info[.originalImage] as? UIImage {
            // 通知 VM 更新圖片
            viewModel.updateImage(originalImage)
        }
        dismiss(animated: true, completion: nil)
    }
}


// MARK: - CollectionView Delegate

extension MemeGeneratorViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // 從 VM 獲得濾鏡數量
        return viewModel.filterPreviews.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCell", for: indexPath) as! FilterCell
        let filterType = FilterType.allCases[indexPath.item]
        // 從 VM 獲得預覽圖片
        cell.overlayImageView.image = viewModel.filterPreviews[indexPath.item]
        cell.overlayImageView.image = UIImage(named: filterType.overlayImageName)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let filterType = FilterType.allCases[indexPath.item]
        if let currentImage = viewModel.currentPetImage {
            // 更新圖片並套用濾鏡
            viewModel.updateImage(viewModel.applyFilter(to: currentImage, filterType: filterType))
        }
        
        let overlayImageName = filterType.overlayImageName
        if let overlayImage = UIImage(named: overlayImageName) {
            let overlayView = UIImageView(image: overlayImage)
            overlayView.isUserInteractionEnabled = true
            overlayView.contentMode = .scaleAspectFit
            
            let overlaySize = originalPetImageView.bounds.size
            overlayView.frame.size = CGSize(width: overlaySize.width * 0.9, height: overlaySize.height * 0.9)
            
            overlayView.center = CGPoint(x: originalPetImageView.bounds.midX, y: originalPetImageView.bounds.midY)
            
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panOverlayView(_:)))
            overlayView.addGestureRecognizer(panGesture)
            
            let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchOverlayView(_:)))
            overlayView.addGestureRecognizer(pinchGesture)
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapOverlayView(_:)))
            overlayView.addGestureRecognizer(tapGesture)
            
            originalPetImageView.addSubview(overlayView)
        }
    }
}

