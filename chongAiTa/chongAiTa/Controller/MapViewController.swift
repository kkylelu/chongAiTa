//
//  MapViewController.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/4/17.
//

import UIKit
import GoogleMaps

class MapViewController: UIViewController {
    
    var mapView: GMSMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    func setupUI() {
        let camera = GMSCameraPosition.camera(withLatitude: 25.039413072140746, longitude: 121.53243457301599, zoom: 16.0)

        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapView)

        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            mapView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            mapView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor)
        ])

        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: 25.039413072140746, longitude: 121.53243457301599)
        marker.title = "AppWorks School"
        marker.snippet = "100台北市中正區仁愛路二段99號"
        marker.map = mapView
    }
}
