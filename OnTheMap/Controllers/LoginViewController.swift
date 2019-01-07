//
//  ViewController.swift
//  OnTheMap
//
//  Created by ABDULRAHMAN ALRAHMA on 12/3/18.
//  Copyright © 2018 ABDULRAHMAN ALRAHMA. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet var usernameLabel: UITextField!
    @IBOutlet var passwordLabel: UITextField!
    
    
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
    }
    
    @IBAction func login() {
        
        guard let username = usernameLabel.text else {
            showAlert(withTitle: "Input Error", withMessage: "please fill username field")
            return
        }
        
        guard let password = passwordLabel.text else {
            showAlert(withTitle: "Input Error", withMessage: "please fill password field")
            return
        }
        
        AuthClient.loginRequest(username, password) { (session, error) in
            if let error = error {
                self.showAlert(withTitle: "Login Failed!", withMessage: error.localizedDescription)
                return
            }
            if let key = session?.account.key {
                self.user = User(first_name: nil, last_name: nil, key: key)
            }
            
            // TODO: Push map view
            let tabBarVC = self.storyboard?.instantiateViewController(withIdentifier: "TabBar")
            self.present(tabBarVC!, animated: true, completion: nil)
        }
    }
}

