//
//  TravelMapViewController.swift
//  Final Project
//
//  Created by Malak Bassam on 2/14/19.
//  Copyright © 2019 Udacity. All rights reserved.
//

import UIKit
import MapKit

class TravelMapViewController: UIViewController, MKMapViewDelegate {
    
    

    
    @IBOutlet var mapView: MKMapView!
    var pinAnnotation: MKPointAnnotation? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        navigationItem.rightBarButtonItem = editButtonItem
        
        if let pins = loadAllPins() {
            showPins(pins)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is PhotoAlbumViewController {
            guard let pin = sender as? Pin else {
                return
            }
            let controller = segue.destination as! PhotoAlbumViewController
            controller.pin = pin
        }
    }
    
    
    @IBAction func addPinGesture(_ sender: UILongPressGestureRecognizer) {
        
        let location = sender.location(in: mapView)
        let locCoord = mapView.convert(location, toCoordinateFrom: mapView)
        
        if sender.state == .began {
            
            pinAnnotation = MKPointAnnotation()
            pinAnnotation!.coordinate = locCoord
            
            print("\(#function) Coordinate: \(locCoord.latitude),\(locCoord.longitude)")
            
            mapView.addAnnotation(pinAnnotation!)
            
        } else if sender.state == .changed {
            pinAnnotation!.coordinate = locCoord
        } else if sender.state == .ended {
            
            _ = Pin(
                latitude: String(pinAnnotation!.coordinate.latitude),
                longitude: String(pinAnnotation!.coordinate.longitude),
                context: DataController.shared().context
            )
            save()
            
        }
    }
    
  
    
    
    private func loadAllPins() -> [Pin]? {
        var pins: [Pin]?
        do {
            try pins = DataController.shared().fetchAllPins(entityName: Pin.name)
        } catch {
            print("\(#function) error:\(error)")
            showInfo(withTitle: "Error", withMessage: "Error while fetching Pin locations: \(error)")
        }
        return pins
    }
    
    private func loadPin(latitude: String, longitude: String) -> Pin? {
        let predicate = NSPredicate(format: "latitude == %@ AND longitude == %@", latitude, longitude)
        var pin: Pin?
        do {
            try pin = DataController.shared().fetchPin(predicate, entityName: Pin.name)
        } catch {
            print("\(#function) error:\(error)")
            showInfo(withTitle: "Error", withMessage: "Error while fetching location: \(error)")
        }
        return pin
    }
    
    func showPins(_ pins: [Pin]) {
        for pin in pins where pin.latitude != nil && pin.longitude != nil {
            let annotation = MKPointAnnotation()
            let lat = Double(pin.latitude!)!
            let lon = Double(pin.longitude!)!
            annotation.coordinate = CLLocationCoordinate2DMake(lat, lon)
            mapView.addAnnotation(annotation)
        }
        mapView.showAnnotations(mapView.annotations, animated: true)
    }
    
}

extension TravelMapViewController {
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = false
            pinView!.pinTintColor = .red
            pinView!.animatesDrop = true
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            self.showInfo(withMessage: "No link defined.")
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        guard let annotation = view.annotation else {
            return
        }
        
        mapView.deselectAnnotation(annotation, animated: true)
        print("\(#function) lat \(annotation.coordinate.latitude) lon \(annotation.coordinate.longitude)")
        let lat = String(annotation.coordinate.latitude)
        let lon = String(annotation.coordinate.longitude)
        if let pin = loadPin(latitude: lat, longitude: lon) {
            if isEditing {
                mapView.removeAnnotation(annotation)
                DataController.shared().context.delete(pin)
                save()
                return
            }
            performSegue(withIdentifier: "showAlbum", sender: pin)
        }
    }
}



