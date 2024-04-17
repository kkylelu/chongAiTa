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

class MapViewController: UIViewController, CLLocationManagerDelegate {
    
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
    }
    
    func setupUI() {
        let camera = GMSCameraPosition.camera(withLatitude: 25.039413072140746, longitude: 121.53243457301599, zoom: 16.0)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapView)
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: 25.039413072140746, longitude: 121.53243457301599)
        marker.title = "AppWorks School"
        marker.snippet = "100台北市中正區仁愛路二段99號"
        marker.map = mapView
        
        let currentLocButton = UIButton(type: .custom)
        currentLocButton.backgroundColor = UIColor.B1
        currentLocButton.layer.cornerRadius = 28
        currentLocButton.layer.shadowOpacity = 0.3
        currentLocButton.layer.shadowRadius = 4
        currentLocButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        let image = UIImage(systemName: "location.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 32, weight: .medium))
        currentLocButton.setImage(image, for: .normal)
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
            currentLocButton.heightAnchor.constraint(equalToConstant: 56)
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
}
