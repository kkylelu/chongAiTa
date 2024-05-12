//
//  MemeGeneratorViewController.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/5/12.
//

import UIKit

class MemeGeneratorViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var petImageView: UIImageView!
    var overlayContainerView: UIView!
    var layerEditingView: UIView!
    var filterCollectionView: UICollectionView!
    let filters = ["None", "Sepia", "Mono", "Noir"]
    let overlayImages = ["speedline", "glasses", "notice", "shine"]
    var filterPreviews: [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupNavigationBar()
        setupLayerEditingView()
        setupFilterCollectionView()
        generateFilterPreviews()
        
        petImageView.image = UIImage(named: "seeDoctorDog")
        generateFilterPreviews()
        
    }
    
    
    // MARK: - Setup UI
    
    func setupUI() {
        applyDynamicBackgroundColor(lightModeColor: .white, darkModeColor: .black)
        
    }
    
    func setupNavigationBar() {
        navigationItem.title = "毛孩表情包"
        let saveButton = UIBarButtonItem(title: "儲存", style: .done, target: self, action: #selector(savePetMeme))
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func setupLayerEditingView() {
        layerEditingView = UIView()
        
        petImageView = UIImageView()
        petImageView.contentMode = .scaleAspectFit
        
        layerEditingView.translatesAutoresizingMaskIntoConstraints = false
        petImageView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(layerEditingView)
        layerEditingView.addSubview(petImageView)
        
        NSLayoutConstraint.activate([
            layerEditingView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            layerEditingView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            layerEditingView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            layerEditingView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.7),
            
            petImageView.leadingAnchor.constraint(equalTo: layerEditingView.leadingAnchor),
            petImageView.trailingAnchor.constraint(equalTo: layerEditingView.trailingAnchor),
            petImageView.topAnchor.constraint(equalTo: layerEditingView.topAnchor),
            petImageView.bottomAnchor.constraint(equalTo: layerEditingView.bottomAnchor)
        ])
        
        setupOverlayContainerView()
    }
    
    func setupOverlayContainerView() {
        overlayContainerView = UIView()
        overlayContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(overlayContainerView)
        
        NSLayoutConstraint.activate([
            overlayContainerView.leadingAnchor.constraint(equalTo: layerEditingView.leadingAnchor),
            overlayContainerView.trailingAnchor.constraint(equalTo: layerEditingView.trailingAnchor),
            overlayContainerView.topAnchor.constraint(equalTo: layerEditingView.topAnchor),
            overlayContainerView.bottomAnchor.constraint(equalTo: layerEditingView.bottomAnchor)
        ])
    }
    
    
    func setupFilterCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        filterCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        filterCollectionView.delegate = self
        filterCollectionView.dataSource = self
        filterCollectionView.register(FilterCell.self, forCellWithReuseIdentifier: "FilterCell")
        filterCollectionView.backgroundColor = .clear
        filterCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(filterCollectionView)
        
        NSLayoutConstraint.activate([
            filterCollectionView.topAnchor.constraint(equalTo: layerEditingView.bottomAnchor),
            filterCollectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            filterCollectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            filterCollectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
    
    // MARK: - Action
    
    @objc func savePetMeme(){
        if let finalMemeImage = combineMeme(){
            UIImageWriteToSavedPhotosAlbum(finalMemeImage, nil, nil, nil)
        }
    }
    
    func combineMeme() -> UIImage? {
        let render = UIGraphicsImageRenderer(size: self.view.bounds.size)
        let combinedImage = render.image { (context) in
            self.view.drawHierarchy(in: self.view.bounds, afterScreenUpdates: true)
        }
        return combinedImage
    }
    
    
    func generateFilterPreviews() {
        guard let originalImage = petImageView.image else { return }
        filterPreviews = filters.map { filterName in
            return applyFilter(to: originalImage, filterName: filterName)
        }
    }
    
    
    
    func applyFilter(to image: UIImage, filterName: String) -> UIImage {
        let context = CIContext(options: nil)
        if filterName == "None" {
            return image
        }
        if let filter = CIFilter(name: filterName) {
            filter.setValue(CIImage(image: image), forKey: kCIInputImageKey)
            if let outputImage = filter.outputImage,
               let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }
        return image
    }
    
    // MARK: - CollectionView Delegate
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCell", for: indexPath) as! FilterCell
        cell.imageView.image = filterPreviews[indexPath.item]
        cell.nameLabel.text = filters[indexPath.item]
        
        // 確保素材數量匹配
        if indexPath.item < overlayImages.count {
            cell.overlayImageView.image = UIImage(named: overlayImages[indexPath.item])
        } else {
            cell.overlayImageView.image = nil
        }
        return cell
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 濾鏡切換
        if let currentImage = petImageView.image {
            let filterName = filters[indexPath.item]
            petImageView.image = applyFilter(to: currentImage, filterName: filterName)
        }
        
        // 新增圖層
        if indexPath.item < overlayImages.count {
            let overlayImageName = overlayImages[indexPath.item]
            if let overlayImage = UIImage(named: overlayImageName) {
                let overlayView = UIImageView(image: overlayImage)
                overlayView.isUserInteractionEnabled = true
                
                let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panOverlayView(_:)))
                overlayView.addGestureRecognizer(panGesture)
                
                let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchOverlayView(_:)))
                overlayView.addGestureRecognizer(pinchGesture)
                
                overlayContainerView.addSubview(overlayView)
            }
        }
    }
    
    @objc func panOverlayView(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: overlayContainerView)
        if let view = gesture.view {
            view.center = CGPoint(x: view.center.x + translation.x, y: view.center.y + translation.y)
        }
        gesture.setTranslation(.zero, in: overlayContainerView)
    }
    
    @objc func pinchOverlayView(_ gesture: UIPinchGestureRecognizer) {
        if let view = gesture.view {
            view.transform = view.transform.scaledBy(x: gesture.scale, y: gesture.scale)
            gesture.scale = 1.0
        }
    }
    
    
}
