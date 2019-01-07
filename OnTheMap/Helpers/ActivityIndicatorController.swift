//
//  ActivityIndicatorController.swift
//  OnTheMap
//
//  Created by ABDULRAHMAN ALRAHMA on 12/11/18.
//  Copyright © 2018 ABDULRAHMAN ALRAHMA. All rights reserved.
//

import UIKit

class ActivityIndicatorController {
    static let sharedInstance = ActivityIndicatorController()
    private let activityIndicator = UIActivityIndicatorView()
    
    //MARK: - Private Methods -
    private func setupLoader() {
        removeLoader()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .gray
    }
    
    //MARK: - Public Methods -
    func showLoader() {
        setupLoader()
        
        let appDel = UIApplication.shared.delegate as! AppDelegate
        let holdingView = appDel.window!.rootViewController!.view!
        
        DispatchQueue.main.async {
            self.activityIndicator.center = holdingView.center
            self.activityIndicator.startAnimating()
            holdingView.addSubview(self.activityIndicator)
            UIApplication.shared.beginIgnoringInteractionEvents()
        }
    }
    
    func removeLoader(){
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.activityIndicator.removeFromSuperview()
            UIApplication.shared.endIgnoringInteractionEvents()
        }
    }
}
