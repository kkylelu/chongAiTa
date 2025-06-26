//
//  MapViewController.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/4/17.
//

import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation
import Alamofire

class MapViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    
    var mapView: GMSMapView!
    var isLayerButtonExpanded = false
    let locationManager = CLLocationManager()
    
    var layerButton: UIButton!
    var animalHospitalButton: UIButton!
    var petFriendlyRestaurantButton: UIButton!
    var petSuppliesButton: UIButton!
    var currentLocButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        setupUI()
        setNavigationTitle(.map)
        
        // 顯示使用者目前位置
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
                
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if #available(iOS 13.0, *), traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            applyMapStyle()
        }
    }

    
    // MARK: - Setup UI
    func setupUI() {
        
        applyDynamicBackgroundColor(lightModeColor: .white, darkModeColor: .black)
        
        let camera = GMSCameraPosition.camera(withLatitude: 25.039413072140746, longitude: 121.53243457301599, zoom: 16.0)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        applyMapStyle()
        
        layerButton = createLayerButton(type: .layer, action: #selector(toggleLayerButtons))
        animalHospitalButton = createLayerButton(type: .animalHospital, action: #selector(findNearbyPlaces(_:)))
        petFriendlyRestaurantButton = createLayerButton(type: .petFriendlyRestaurant, action: #selector(findNearbyPlaces(_:)))
        petSuppliesButton = createLayerButton(type: .petStore, action: #selector(findNearbyPlaces(_:)))
        currentLocButton = createLayerButton(type: .currentLocation, action: #selector(goToCurrentLocation))
        
        view.addSubview(mapView)
        view.addSubview(layerButton)
        view.addSubview(currentLocButton)
        view.addSubview(animalHospitalButton)
        view.addSubview(petFriendlyRestaurantButton)
        view.addSubview(petSuppliesButton)
        
        animalHospitalButton.tag = LayerButtonType.animalHospital.rawValue
        petFriendlyRestaurantButton.tag = LayerButtonType.petFriendlyRestaurant.rawValue
        petSuppliesButton.tag = LayerButtonType.petStore.rawValue
        
        
        animalHospitalButton.center = layerButton.center
        petFriendlyRestaurantButton.center = layerButton.center
        petSuppliesButton.center = layerButton.center
        
        animalHospitalButton.alpha = 0
        petFriendlyRestaurantButton.alpha = 0
        petSuppliesButton.alpha = 0
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            mapView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            mapView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            
            currentLocButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
            currentLocButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -25),
            currentLocButton.widthAnchor.constraint(equalToConstant: 56),
            currentLocButton.heightAnchor.constraint(equalToConstant: 56),
            
            layerButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
            layerButton.bottomAnchor.constraint(equalTo: currentLocButton.topAnchor, constant: -15),
            layerButton.widthAnchor.constraint(equalToConstant: 56),
            layerButton.heightAnchor.constraint(equalToConstant: 56),
        ])
    }
    
    func applyMapStyle() {
        if traitCollection.userInterfaceStyle == .dark {
            if let styleURL = Bundle.main.url(forResource: "style", withExtension: "json") {
                do {
                    mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
                } catch {
                    NSLog("無法載入地圖樣式: \(error)")
                }
            } else {
                NSLog("找不到 style.json")
            }
        } else {
            mapView.mapStyle = nil
        }
    }

    func createLayerButton(type: LayerButtonType, action: Selector?) -> UIButton {
        let button = UIButton(type: .custom)
        button.backgroundColor = type.backgroundColor
        button.layer.cornerRadius = 28
        button.layer.shadowOpacity = 0.3
        button.layer.shadowRadius = 4
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.setImage(type.image, for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 56).isActive = true
        button.heightAnchor.constraint(equalToConstant: 56).isActive = true
        
        if let action = action {
            button.addTarget(self, action: action, for: .touchUpInside)
        }
        
        switch type {
        case .animalHospital:
            button.addTarget(self, action: #selector(findNearbyPlaces(_:)), for: .touchUpInside)
        case .petFriendlyRestaurant:
            button.addTarget(self, action: #selector(findNearbyPlaces(_:)), for: .touchUpInside)
        case .petStore:
            button.addTarget(self, action: #selector(findNearbyPlaces(_:)), for: .touchUpInside)
        default:
            break
        }
        
        return button
    }
    
    func setupCurrentLocButton() {
        let currentLocButton = view.subviews.compactMap({ $0 as? UIButton }).first(where: { $0.currentImage == UIImage(systemName: "mappin.and.ellipse") }) //"location.fill"
        currentLocButton?.addTarget(self, action: #selector(goToCurrentLocation), for: .touchUpInside)
    }
    
    // MARK: - Action
    @objc func goToCurrentLocation() {
        // 提供觸覺回饋
        let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        impactFeedbackGenerator.prepare()
        impactFeedbackGenerator.impactOccurred()
        
        mapView.clear()
        if CLLocationManager.locationServicesEnabled() {
            if let location = locationManager.location {
                let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: mapView.camera.zoom)
                mapView.animate(to: camera)
            }
        }
    }
    
    @objc func toggleLayerButtons() {
        // 提供觸覺回饋
        let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        impactFeedbackGenerator.prepare()
        impactFeedbackGenerator.impactOccurred()
        
        isLayerButtonExpanded.toggle()
        
        UIView.animate(withDuration: 0.3) {
            if self.isLayerButtonExpanded {
                
                self.animalHospitalButton.alpha = 1
                self.petFriendlyRestaurantButton.alpha = 1
                self.petSuppliesButton.alpha = 1
                
                self.animalHospitalButton.isUserInteractionEnabled = true
                self.petFriendlyRestaurantButton.isUserInteractionEnabled = true
                self.petSuppliesButton.isUserInteractionEnabled = true
                
                self.animalHospitalButton.center = CGPoint(x: self.layerButton.center.x - 80, y: self.layerButton.center.y - 80)
                self.petFriendlyRestaurantButton.center = CGPoint(x: self.layerButton.center.x - 80, y: self.layerButton.center.y)
                self.petSuppliesButton.center = CGPoint(x: self.layerButton.center.x - 80, y: self.layerButton.center.y + 80)
            } else {
                
                self.animalHospitalButton.center = self.layerButton.center
                self.petFriendlyRestaurantButton.center = self.layerButton.center
                self.petSuppliesButton.center = self.layerButton.center
                
                self.animalHospitalButton.alpha = 0
                self.petFriendlyRestaurantButton.alpha = 0
                self.petSuppliesButton.alpha = 0
                
                self.animalHospitalButton.isUserInteractionEnabled = false
                self.petFriendlyRestaurantButton.isUserInteractionEnabled = false
                self.petSuppliesButton.isUserInteractionEnabled = false
            }
        }
    }
    
    @objc func findNearbyPlaces(_ sender: UIButton) {
        // 提供觸覺回饋
        let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        impactFeedbackGenerator.prepare()
        impactFeedbackGenerator.impactOccurred()
        
        guard let buttonType = LayerButtonType(rawValue: sender.tag) else {
            print("未設定按鈕類型")
            return
        }
        
        guard let location = locationManager.location else {
            print("無法獲取用戶位置")
            return
        }
        
        mapView.clear()
        
        // 使用新的 Places API (New) - Nearby Search
        let apiKeys = APIKeys(resourceName: "API-Keys")
        let googlePlacesAPIKey = apiKeys.googlePlacesAPIKey
        
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        
        // 根據按鈕類型設定搜尋的地點類型（使用新的 Places API 類型）
        var includedTypes: [String] = []
        switch buttonType {
        case .animalHospital:
            includedTypes = ["veterinary_care"]
        case .petFriendlyRestaurant:
            includedTypes = ["restaurant"]
        case .petStore:
            includedTypes = ["pet_store"]
        default:
            break
        }
        
        // 建立新的 Places API (New) 請求
        let url = "https://places.googleapis.com/v1/places:searchNearby"
        
        // 建立請求參數（使用新的 API 格式）
        let parameters: [String: Any] = [
            "includedTypes": includedTypes,
            "maxResultCount": 20,
            "locationRestriction": [
                "circle": [
                    "center": [
                        "latitude": latitude,
                        "longitude": longitude
                    ],
                    "radius": 3000.0
                ]
            ]
        ]
        
        // 設定標頭（新的 API 需要特殊標頭）
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "X-Goog-Api-Key": googlePlacesAPIKey,
            "X-Goog-FieldMask": "places.displayName,places.location,places.formattedAddress,places.id,places.types,places.rating,places.internationalPhoneNumber"
        ]
        
        print("🔍 使用新的 Places API 搜尋 \(buttonType.rawValue) 類型的地點...")
        
        // 針對寵物友善餐廳，使用文字搜尋會更精確
        if buttonType == .petFriendlyRestaurant {
            performPetFriendlyRestaurantSearch(near: location.coordinate)
            return
        }
        
        NetworkManager.shared.request(url: url, method: .post, parameters: parameters, headers: headers) { (result: Result<NewPlacesResponse, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    let places = data.places ?? []
                    print("✅ 新的 Places API 搜尋成功：找到 \(places.count) 個地點")
                    
                    for place in places {
                        self.addNewPlaceMarker(place)
                    }
                    
                    if places.isEmpty {
                        print("⚠️ 警告：搜尋成功但沒有找到任何地點")
                    }
                case .failure(let error):
                    print("❌ 新的 Places API 搜尋失敗：\(error.localizedDescription)")
                    // 降級到舊版 API 作為備用
                    self.fallbackToLegacyAPI(buttonType: buttonType, location: location)
                }
            }
        }
    }
    
    // 備用方法：使用舊版 Places API
    private func fallbackToLegacyAPI(buttonType: LayerButtonType, location: CLLocation) {
        print("🔄 降級使用舊版 Places API...")
        
        let type = buttonType.placesType
        let apiKeys = APIKeys(resourceName: "API-Keys")
        let googlePlacesAPIKey = apiKeys.googlePlacesAPIKey
        
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        let radius = 3000
        
        let url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(latitude),\(longitude)&radius=\(radius)&type=\(type)&key=\(googlePlacesAPIKey)"
        
        NetworkManager.shared.request(url: url, method: .get, parameters: nil, headers: HTTPHeaders()) { (result: Result<PlacesResponse, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    print("✅ 舊版 Places API 搜尋成功：找到 \(data.results.count) 個地點")
                    for place in data.results {
                        self.addPlaceMarker(place)
                    }
                case .failure(let error):
                    print("❌ 舊版 Places API 也失敗：\(error.localizedDescription)")
                }
            }
        }
    }
    
    // 搜尋寵物友善餐廳的方法
    private func performPetFriendlyRestaurantSearch(near coordinate: CLLocationCoordinate2D) {
        print("🐕 開始搜尋寵物友善餐廳...")
        
        let apiKeys = APIKeys(resourceName: "API-Keys")
        let googlePlacesAPIKey = apiKeys.googlePlacesAPIKey
        
        // 使用新的 Places API (New) 的文字搜尋
        let url = "https://places.googleapis.com/v1/places:searchText"
        
        // 建立搜尋參數
        let parameters: [String: Any] = [
            "textQuery": "寵物餐廳",
            "maxResultCount": 20,
            "locationBias": [
                "circle": [
                    "center": [
                        "latitude": coordinate.latitude,
                        "longitude": coordinate.longitude
                    ],
                    "radius": 5000.0  // 擴大搜尋範圍到5km
                ]
            ]
        ]
        
        // 設定標頭
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "X-Goog-Api-Key": googlePlacesAPIKey,
            "X-Goog-FieldMask": "places.displayName,places.location,places.formattedAddress,places.id,places.types,places.rating,places.internationalPhoneNumber"
        ]
        
        NetworkManager.shared.request(url: url, method: .post, parameters: parameters, headers: headers) { (result: Result<NewPlacesResponse, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    let places = data.places ?? []
                    print("✅ 寵物友善餐廳搜尋成功：找到 \(places.count) 個地點")
                    
                    for place in places {
                        self.addNewPlaceMarker(place)
                    }
                    
                    if places.isEmpty {
                        print("⚠️ 沒有找到寵物友善餐廳，嘗試一般餐廳搜尋...")
                        self.performGeneralRestaurantSearch(near: coordinate)
                    }
                case .failure(let error):
                    print("❌ 寵物友善餐廳搜尋失敗：\(error.localizedDescription)")
                    // 降級到一般餐廳搜尋
                    self.performGeneralRestaurantSearch(near: coordinate)
                }
            }
        }
    }
    
    // 一般餐廳搜尋作為備用
    private func performGeneralRestaurantSearch(near coordinate: CLLocationCoordinate2D) {
        print("🍽️ 執行一般餐廳搜尋...")
        
        let apiKeys = APIKeys(resourceName: "API-Keys")
        let googlePlacesAPIKey = apiKeys.googlePlacesAPIKey
        
        // 使用新的 Places API (New) - Nearby Search 搜尋餐廳
        let url = "https://places.googleapis.com/v1/places:searchNearby"
        
        let parameters: [String: Any] = [
            "includedTypes": ["restaurant"],
            "maxResultCount": 15,
            "locationRestriction": [
                "circle": [
                    "center": [
                        "latitude": coordinate.latitude,
                        "longitude": coordinate.longitude
                    ],
                    "radius": 3000.0
                ]
            ]
        ]
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "X-Goog-Api-Key": googlePlacesAPIKey,
            "X-Goog-FieldMask": "places.displayName,places.location,places.formattedAddress,places.id,places.types,places.rating,places.internationalPhoneNumber"
        ]
        
        NetworkManager.shared.request(url: url, method: .post, parameters: parameters, headers: headers) { (result: Result<NewPlacesResponse, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    let places = data.places ?? []
                    print("✅ 一般餐廳搜尋成功：找到 \(places.count) 個地點")
                    
                    for place in places {
                        self.addNewPlaceMarker(place)
                    }
                case .failure(let error):
                    print("❌ 一般餐廳搜尋也失敗：\(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - CLLocationManager Delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
                // 只在第一次定位時設定地圖相機位置
                if mapView.camera.target.latitude == 0 && mapView.camera.target.longitude == 0 {
                    let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: 16.0)
                    mapView.animate(to: camera)
                }
            }
        }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("找不到使用者的位置: \(error.localizedDescription)")
    }
    
    func addPlaceMarker(_ place: Place) {
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: place.geometry.location.lat, longitude: place.geometry.location.lng)
        marker.title = place.name
        marker.snippet = place.vicinity
        marker.userData = place
        marker.map = mapView
    }
    
    func addNewPlaceMarker(_ place: NewPlace) {
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: place.location.latitude, longitude: place.location.longitude)
        marker.title = place.displayName?.text ?? "未知地點"
        marker.snippet = place.formattedAddress ?? ""
        marker.userData = place
        marker.map = mapView
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        
        // 處理新版 Places API 的地點
        if let newPlace = marker.userData as? NewPlace {
            let alertController = UIAlertController(
                title: "導航到 \(newPlace.displayName?.text ?? "此地點")",
                message: "你想要打開 Google 地圖進行導航嗎？",
                preferredStyle: .alert
            )
            
            let openAction = UIAlertAction(title: "打開", style: .default) { _ in
                if let url = URL(string: "comgooglemaps://?saddr=&daddr=\(newPlace.location.latitude),\(newPlace.location.longitude)&directionsmode=driving"),
                   UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else if let webUrl = URL(string: "https://www.google.com/maps/dir/?api=1&destination=\(newPlace.location.latitude),\(newPlace.location.longitude)&travelmode=driving") {
                    UIApplication.shared.open(webUrl, options: [:], completionHandler: nil)
                }
            }
            
            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            
            alertController.addAction(openAction)
            alertController.addAction(cancelAction)
            
            present(alertController, animated: true, completion: nil)
            return
        }
        
        // 處理舊版 Places API 的地點
        guard let place = marker.userData as? Place else {
            print("錯誤：無法獲取地點資料")
            return
        }
        
        let alertController = UIAlertController(
            title: "導航到 \(place.name)",
            message: "你想要打開 Google 地圖進行導航嗎？",
            preferredStyle: .alert
        )
        
        let openAction = UIAlertAction(title: "打開", style: .default) { _ in
            if let url = URL(string: "comgooglemaps://?saddr=&daddr=\(place.geometry.location.lat),\(place.geometry.location.lng)&directionsmode=driving"),
               UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else if let webUrl = URL(string: "https://www.google.com/maps/dir/?api=1&destination=\(place.geometry.location.lat),\(place.geometry.location.lng)&travelmode=driving") {
                UIApplication.shared.open(webUrl, options: [:], completionHandler: nil)
            }
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alertController.addAction(openAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
}
