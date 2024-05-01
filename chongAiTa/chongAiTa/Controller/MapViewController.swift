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

class MapViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    
    var mapView: GMSMapView!
    var isLayerButtonExpanded = false
    let locationManager = CLLocationManager()
    
    var layerButton: UIButton!
    var animalHospitalButton: UIButton!
    var parkButton: UIButton!
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
    
    // MARK: - Setup UI
    func setupUI() {
        
        let camera = GMSCameraPosition.camera(withLatitude: 25.039413072140746, longitude: 121.53243457301599, zoom: 16.0)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        layerButton = createLayerButton(type: .layer, action: #selector(toggleLayerButtons))
        animalHospitalButton = createLayerButton(type: .animalHospital, action: #selector(findNearbyPlaces(_:)))
        parkButton = createLayerButton(type: .park, action: #selector(findNearbyPlaces(_:)))
        petSuppliesButton = createLayerButton(type: .petStore, action: #selector(findNearbyPlaces(_:)))
        currentLocButton = createLayerButton(type: .currentLocation, action: #selector(goToCurrentLocation))
        
        view.addSubview(mapView)
        view.addSubview(layerButton)
        view.addSubview(currentLocButton)
        view.addSubview(animalHospitalButton)
        view.addSubview(parkButton)
        view.addSubview(petSuppliesButton)
        
        animalHospitalButton.tag = LayerButtonType.animalHospital.rawValue
        parkButton.tag = LayerButtonType.park.rawValue
        petSuppliesButton.tag = LayerButtonType.petStore.rawValue
        
        
        animalHospitalButton.center = layerButton.center
        parkButton.center = layerButton.center
        petSuppliesButton.center = layerButton.center
        
        animalHospitalButton.alpha = 0
        parkButton.alpha = 0
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
        case .park:
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
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    @objc func toggleLayerButtons() {
        isLayerButtonExpanded.toggle()
        
        UIView.animate(withDuration: 0.3) {
            if self.isLayerButtonExpanded {
                
                self.animalHospitalButton.alpha = 1
                self.parkButton.alpha = 1
                self.petSuppliesButton.alpha = 1
                
                self.animalHospitalButton.isUserInteractionEnabled = true
                self.parkButton.isUserInteractionEnabled = true
                self.petSuppliesButton.isUserInteractionEnabled = true
                
                self.animalHospitalButton.center = CGPoint(x: self.layerButton.center.x - 80, y: self.layerButton.center.y - 80)
                self.parkButton.center = CGPoint(x: self.layerButton.center.x - 80, y: self.layerButton.center.y)
                self.petSuppliesButton.center = CGPoint(x: self.layerButton.center.x - 80, y: self.layerButton.center.y + 80)
            } else {
                
                self.animalHospitalButton.center = self.layerButton.center
                self.parkButton.center = self.layerButton.center
                self.petSuppliesButton.center = self.layerButton.center
                
                self.animalHospitalButton.alpha = 0
                self.parkButton.alpha = 0
                self.petSuppliesButton.alpha = 0
                
                self.animalHospitalButton.isUserInteractionEnabled = false
                self.parkButton.isUserInteractionEnabled = false
                self.petSuppliesButton.isUserInteractionEnabled = false
            }
        }
    }
    
    @objc func findNearbyPlaces(_ sender: UIButton) {
        guard let buttonType = LayerButtonType(rawValue: sender.tag) else {
            print("未設定按鈕類型")
            return
        }
        
        let type = buttonType.placesType
        guard let location = locationManager.location else {
            print("無法獲取用戶位置")
            return
        }
        
        mapView.clear()
        
        let apiKeys = APIKeys(resourceName: "API-Keys")
        let googlePlacesAPIKey = apiKeys.googlePlacesAPIKey
        
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        let radius = 3000  // 查詢範圍為 3000 公尺
        
        let url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(latitude),\(longitude)&radius=\(radius)&type=\(type)&key=\(googlePlacesAPIKey)"
        
        NetworkManager.shared.request(url: url, method: .get, parameters: nil, headers: []) { (result: Result<PlacesResponse, Error>) in
            switch result {
            case .success(let data):
                for place in data.results {
                    self.addPlaceMarker(place)
                }
            case .failure(let error):
                print("錯誤：\(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - CLLocationManager Delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: 16.0)
            mapView.animate(to: camera)
            
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
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        
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
                // 如果有安裝 Google 地圖 App 就打開
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else if let webUrl = URL(string: "https://www.google.com/maps/dir/?api=1&destination=\(place.geometry.location.lat),\(place.geometry.location.lng)&travelmode=driving") {
                // 如果沒有地圖 App，打開瀏覽器中的 Google 地圖
                UIApplication.shared.open(webUrl, options: [:], completionHandler: nil)
            }
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alertController.addAction(openAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    
    
}
