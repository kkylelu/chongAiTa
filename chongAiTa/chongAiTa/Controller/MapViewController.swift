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
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        setupUI()
        setupCurrentLocButton()
        
        // 顯示使用者目前位置
        mapView.isMyLocationEnabled = true
        
        mapView.delegate = self

    }
    
    func setupUI() {
                
        let camera = GMSCameraPosition.camera(withLatitude: 25.039413072140746, longitude: 121.53243457301599, zoom: 16.0)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapView)
        
//        let marker = GMSMarker()
//        marker.position = CLLocationCoordinate2D(latitude: 25.039413072140746, longitude: 121.53243457301599)
//        marker.title = "AppWorks School"
//        marker.snippet = "100台北市中正區仁愛路二段99號"
//        marker.map = mapView
        
        let hospitalButton = UIButton(type: .custom)
        hospitalButton.backgroundColor = UIColor.hexStringToUIColor(hex: "#FEAABC")
        hospitalButton.layer.cornerRadius = 28
        hospitalButton.layer.shadowOpacity = 0.3
        hospitalButton.layer.shadowRadius = 4
        hospitalButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        let hospitalButtonImage = UIImage(systemName: "cross.case.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 32, weight: .medium))
        hospitalButton.setImage(hospitalButtonImage, for: .normal)
        hospitalButton.tintColor = .white
        hospitalButton.translatesAutoresizingMaskIntoConstraints = false
        hospitalButton.addTarget(self, action: #selector(findNearbyAnimalHospitals), for: .touchUpInside)
        view.addSubview(hospitalButton)
        
        let currentLocButton = UIButton(type: .custom)
        currentLocButton.backgroundColor = UIColor.B1
        currentLocButton.layer.cornerRadius = 28
        currentLocButton.layer.shadowOpacity = 0.3
        currentLocButton.layer.shadowRadius = 4
        currentLocButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        let currentLocButtonImage = UIImage(systemName: "location.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 32, weight: .medium))
        currentLocButton.setImage(currentLocButtonImage, for: .normal)
        currentLocButton.tintColor = .white
        currentLocButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(currentLocButton)
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            mapView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            mapView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            
            currentLocButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
            currentLocButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -25),
            currentLocButton.widthAnchor.constraint(equalToConstant: 56),
            currentLocButton.heightAnchor.constraint(equalToConstant: 56),
            
            hospitalButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
            hospitalButton.bottomAnchor.constraint(equalTo: currentLocButton.topAnchor, constant: -15),
            hospitalButton.widthAnchor.constraint(equalToConstant: 56),
            hospitalButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
    
    func setupCurrentLocButton() {
        let currentLocButton = view.subviews.compactMap({ $0 as? UIButton }).first(where: { $0.currentImage == UIImage(systemName: "location.fill") })
        currentLocButton?.addTarget(self, action: #selector(goToCurrentLocation), for: .touchUpInside)
    }
    
    @objc func goToCurrentLocation() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    // CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: 16.0)
            mapView.animate(to: camera)
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("找不到使用者的位置: \(error.localizedDescription)")
    }
    
    @objc func findNearbyAnimalHospitals() {
        guard let location = locationManager.location else {
            print("無法獲取用戶位置")
            return
        }
        
        let apiKeys = APIKeys(resourceName: "API-Keys")
        let googlePlacesAPIKey = apiKeys.googlePlacesAPIKey
        
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        // 查詢範圍為 5000 公尺
        let radius = 5000
        let type = "veterinary_care"
        
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
