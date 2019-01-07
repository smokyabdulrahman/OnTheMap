//
//  StudentLocationsTableViewController.swift
//  OnTheMap
//
//  Created by ABDULRAHMAN ALRAHMA on 12/6/18.
//  Copyright © 2018 ABDULRAHMAN ALRAHMA. All rights reserved.
//

import UIKit

class StudentLocationsTableViewController: UITableViewController {
    
    private let cellIdentifier: String = "tableCell"
    
    var studentLocations: [StudentLocation] {
        get {
            return (UIApplication.shared.delegate as! AppDelegate).studentLocations
        }
        set {
            (UIApplication.shared.delegate as! AppDelegate).studentLocations = newValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(getStudentsLocations))
        navigationItem.rightBarButtonItems = ([navigationItem.rightBarButtonItem, refreshButton] as! [UIBarButtonItem])
        
    }
    
    @objc private func getStudentsLocations() {
        ParseClient.getStudentsLocations { (studentsLocations, error) in
            if let error = error {
                self.showAlert(withTitle: "Oppss!", withMessage: error.localizedDescription)
                ActivityIndicatorController.sharedInstance.removeLoader()
                return
            }
            self.studentLocations = studentsLocations
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return studentLocations.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        guard let first = studentLocations[indexPath.row].firstName, let last = studentLocations[indexPath.row].lastName, let urlString = studentLocations[indexPath.row].mediaURL else {
            return UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
        }
        cell.textLabel?.text = "\(first) \(last)"
        cell.detailTextLabel?.text = "\(urlString)"
        cell.imageView?.image = UIImage(named: "udacity")
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let urlString = studentLocations[indexPath.row].mediaURL else {
            return
        }
        guard let url = URL(string: urlString) else {
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

}
