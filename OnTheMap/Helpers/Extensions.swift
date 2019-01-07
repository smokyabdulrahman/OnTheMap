//
//  Extensions.swift
//  OnTheMap
//
//  Created by ABDULRAHMAN ALRAHMA on 12/4/18.
//  Copyright © 2018 ABDULRAHMAN ALRAHMA. All rights reserved.
//

import UIKit

extension UIViewController {
    func showAlert(withTitle title: String, withMessage message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "LOGOUT", style: .plain, target: self, action: #selector(logout))
        let addPinButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(presentAddPinView))
        navigationItem.rightBarButtonItem = addPinButton
    }
    
    @objc func logout() {
        AuthClient.deleteSession { (succeeded) in
            if succeeded {
                DispatchQueue.main.async {
                    self.tabBarController?.dismiss(animated: true, completion: nil)
                }
            } else {
                self.showAlert(withTitle: "Opps!", withMessage: "Something went wrong and couldn't signout. Try again, please.")
            }
        }
    }
    
    @objc func presentAddPinView() {
        let addPinVC = storyboard?.instantiateViewController(withIdentifier: "AddPinViewController") as! AddPinViewController
        present(addPinVC, animated: true, completion: nil)
    }
    
}
