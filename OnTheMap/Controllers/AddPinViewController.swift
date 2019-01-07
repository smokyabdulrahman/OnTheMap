//
//  AddPinViewController.swift
//  OnTheMap
//
//  Created by ABDULRAHMAN ALRAHMA on 12/9/18.
//  Copyright © 2018 ABDULRAHMAN ALRAHMA. All rights reserved.
//

import UIKit
import MapKit

class AddPinViewController: UIViewController {
    
    @IBOutlet var locationField: UITextField!
    @IBOutlet var websiteField: UITextField!
    @IBOutlet var findLocationButton: UIButton!
    
    var user: User {
        get {
            return (UIApplication.shared.delegate as! AppDelegate).user
        }
        set {
            (UIApplication.shared.delegate as! AppDelegate).user = newValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func dismiss() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addPin() {
        let geoCoder = CLGeocoder()
        
        guard let locationString = locationField.text else {
            showAlert(withTitle: "Fields are not filled", withMessage: "Please, fill location field.")
            return
        }
        
        isLoading(true)
        
        geoCoder.geocodeAddressString(locationString) { (placemarks, error) in
            guard let placemarks = placemarks else {
                self.showAlert(withTitle: "Error", withMessage: "Entered address is not valid!")
                self.locationField.text = ""
                self.isLoading(false)
                return
            }
            
            guard let placemark = placemarks.first else {
                self.showAlert(withTitle: "Sorry!", withMessage: "Couldn't find the location coordinates for entered address.")
                self.isLoading(false)
                return
            }

            guard let coordinate = placemark.location?.coordinate else {
                self.showAlert(withTitle: "Sorry!", withMessage: "Couldn't find the location coordinates for entered address.")
                self.isLoading(false)
                return
            }
            
            // TODO: get user info
            guard let userKey = self.user.key else {
                self.showAlert(withTitle: "Error", withMessage: "Can't find current user key to post new pin!")
                self.isLoading(false)
                return
            }
            
            AuthClient.getUserInfo(withKey: userKey, completionHandler: { (user, error) in
                guard let user = user else {
                    self.showAlert(withTitle: "Error", withMessage: (error?.localizedDescription)!)
                    self.isLoading(false)
                    return
                }
                guard let first_name = user.first_name, let last_name = user.last_name, let key = user.key else {
                    self.showAlert(withTitle: "Error", withMessage: "Retrieved data didn't include wanted information, try again.")
                    self.isLoading(false)
                    return
                }
                
                self.user = User(first_name: first_name, last_name: last_name, key: key)
                
                // TODO: Upload/POST studentLocation to API
                let latitude: Double = coordinate.latitude
                let longitude: Double = coordinate.longitude
                
                let studentLoaction = StudentLocationBody(uniqueKey: self.user.key!, firstName: self.user.first_name!, lastName: self.user.last_name!, mapString: placemark.name!, mediaURL: self.websiteField.text!, latitude: latitude, longitude: longitude)
                
                ParseClient.postStudentLocation(studentLoaction, completionHandler: { (studentLocation, error) in
                    if let _ = error {
                        self.showAlert(withTitle: "Error", withMessage: "Couldn't post new pin, please try again.")
                        self.isLoading(false)
                        return
                    } else {
                        // init postedLocation
                        (UIApplication.shared.delegate as! AppDelegate).postedLocation = coordinate
                    }
                    self.isLoading(false)
                    self.dismiss(animated: true, completion: nil)
                })
            })
        }
    }
    
    func isLoading(_ loading: Bool){
        findLocationButton.isEnabled = !loading
    }

}
