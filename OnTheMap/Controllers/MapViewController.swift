//
//  MapViewController.swift
//  OnTheMap
//
//  Created by ABDULRAHMAN ALRAHMA on 12/5/18.
//  Copyright © 2018 ABDULRAHMAN ALRAHMA. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var loadingView: UIView!
    
    private var mapAnnotations: [MKPointAnnotation]!
    var studentLocations: [StudentLocation] {
        get {
            return (UIApplication.shared.delegate as! AppDelegate).studentLocations
        }
        set {
            (UIApplication.shared.delegate as! AppDelegate).studentLocations = newValue
        }
    }
    
    private let annotiationReuseId = "annotation"
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(getStudentsLocations))
        navigationItem.rightBarButtonItems = ([navigationItem.rightBarButtonItem, refreshButton] as! [UIBarButtonItem])
        
        mapView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getStudentsLocations()
    }
    
    @objc private func getStudentsLocations() {
        setLoading(true)
        ParseClient.getStudentsLocations { (studentsLocations, error) in
            if let error = error {
                self.showAlert(withTitle: "Oppss!", withMessage: error.localizedDescription)
                self.setLoading(false);
                return
            }
            self.studentLocations = studentsLocations
            self.loadMapAnnotations()
        }
    }
    
    private func loadMapAnnotations() {
        mapAnnotations = [MKPointAnnotation]()

        for location in studentLocations {
            let annotation = MKPointAnnotation()
            
            // check if entery has wanted values, else go to next entery
            guard let _ = location.longitude else {
                continue
            }
            
            // Notice that the float values are being used to create CLLocationDegree values.
            // This is a version of the Double type.
            let lat = CLLocationDegrees(location.latitude!)
            let long = CLLocationDegrees(location.longitude!)
            
            // The lat and long are used to create a CLLocationCoordinates2D instance.
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let first = location.firstName!
            let last = location.lastName!
            if let mediaURL = location.mediaURL {
                annotation.subtitle = mediaURL
            }
            
            // Here we create the annotation and set its coordiate, title, and subtitle properties
            annotation.coordinate = coordinate
            annotation.title = "\(first) \(last)"
            
            // Finally we place the annotation in an array of annotations.
            mapAnnotations.append(annotation)
        }
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotations(mapAnnotations)
        checkIfUserAddedLocation()
        setLoading(false);
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
        
        if let pinView = pinView {
            pinView.annotation = annotation
        } else {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            guard let urlString = view.annotation?.subtitle! else {
                showAlert(withTitle: "Opps!", withMessage: "There isn't a url to open.")
                return
            }
            guard let url = URL(string: urlString) else {
                showAlert(withTitle: "Opps!", withMessage: "The url seems unsupported.")
                return
            }
            app.open(url, options: [:], completionHandler: nil)
        }
    }
    
    private func setLoading(_ isLoading: Bool) {
        loadingView.isHidden = !isLoading
    }
    
    private func checkIfUserAddedLocation() {
        // check if user posted a location
        if let postedLocation = (UIApplication.shared.delegate as! AppDelegate).postedLocation {
            let region = MKCoordinateRegion(center: postedLocation, span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
            mapView.setRegion(region, animated: true)
            // delete posted location
            (UIApplication.shared.delegate as! AppDelegate).postedLocation = nil
        }
    }
}
