//
//  LocationPickerViewController.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 18/06/21.
//

import CoreLocation
import MapKit

protocol LocationPickerProtocol: AnyObject {
    func tryingToLocationSendMessage(with Location: CLLocationCoordinate2D)
}

class LocationPickerViewController: UIViewController {
    var coordinates: CLLocationCoordinate2D?
    weak var delegate: LocationPickerProtocol?
    
    private lazy var map : MKMapView = {
        let map = MKMapView()
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapMap))
        gesture.numberOfTouchesRequired = 1
        gesture.numberOfTapsRequired = 1
        map.isUserInteractionEnabled = true
        map.addGestureRecognizer(gesture)
        return map
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(map)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        map.frame = view.bounds
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapSend))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                           style: .done,
                                                           target: self,
                                                           action: #selector(didTapCancel))
    }
    
    @objc func didTapMap(_ gesture: UITapGestureRecognizer) {
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
