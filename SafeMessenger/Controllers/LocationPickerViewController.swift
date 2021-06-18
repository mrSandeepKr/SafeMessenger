//
//  LocationPickerViewController.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 18/06/21.
//

import CoreLocation
import MapKit
import UIKit

protocol LocationPickerProtocol: AnyObject {
    func tryingToLocationSendMessage(with Location: CLLocationCoordinate2D)
}

class LocationPickerViewController: UIViewController {
    var coordinates: CLLocationCoordinate2D?
    weak var delegate: LocationPickerProtocol?
    var isViewingMode = false
    
    private lazy var map : MKMapView = {
        let map = MKMapView()
        map.isUserInteractionEnabled = true
        return map
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(map)
        if isViewingMode {
            guard let coordinates = coordinates else {
                return
            }
            let pin = MKPointAnnotation()
            pin.coordinate = coordinates
            map.addAnnotation(pin)
            
            CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: coordinates.latitude,
                                                           longitude: coordinates.longitude)) {[weak self] placemarks, err in
                guard err == nil,
                      let placemark = placemarks?.first,
                      let strongSelf = self,
                      let coordinates = strongSelf.coordinates
                else {
                    return
                }
                print("LocationPickerViewController: Got the locality")
                let pin1 = MKPointAnnotation.init()
                pin1.coordinate = coordinates
                pin1.title  = placemark.locality
                
                let coordinateRegion = MKCoordinateRegion(center: coordinates,
                                                          latitudinalMeters: 8000,
                                                          longitudinalMeters: 8000)
                strongSelf.map.setRegion(coordinateRegion, animated: true)
                strongSelf.map.removeAnnotations(strongSelf.map.annotations)
                strongSelf.map.addAnnotation(pin1)
            }
        }
        else {
            let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapMap))
            gesture.numberOfTouchesRequired = 1
            gesture.numberOfTapsRequired = 1
            map.addGestureRecognizer(gesture)
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send",
                                                                style: .done,
                                                                target: self,
                                                                action: #selector(didTapSend))
        }
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                           style: .done,
                                                           target: self,
                                                           action: #selector(didTapCancel))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        map.frame = view.bounds
    }
    
    @objc func didTapMap(_ gesture: UITapGestureRecognizer) {
        guard !isViewingMode else {
            return
        }
        let locationPointInView = gesture.location(in: map)
        let coordinates = map.convert(locationPointInView, toCoordinateFrom: map)
        
        self.coordinates = coordinates
        let pin = MKPointAnnotation()
        pin.coordinate = coordinates
        map.removeAnnotations(map.annotations)
        map.addAnnotation(pin)
    }
    
    @objc func didTapCancel() {
        dismiss(animated: true)
    }
    
    @objc private func didTapSend() {
        guard let coordinates = coordinates else {
            let alert = UIAlertController(title: "No Location Selected",
                                          message: nil,
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK",style: .destructive))
            present(alert, animated: true, completion: nil)
            return
        }
        delegate?.tryingToLocationSendMessage(with: coordinates)
        dismiss(animated: true)
    }
}
