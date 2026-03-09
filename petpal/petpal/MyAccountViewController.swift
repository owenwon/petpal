//
//  MyAccountViewController.swift
//  petpal
//
//  Created by Owen Wong on 3/8/26.
//

import UIKit

class MyAccountViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    // MARK: - Table View Functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MockDatabase.jobs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "JobCell", for: indexPath) as! JobCell
        
        let job = MockDatabase.jobs[indexPath.row]
        
        cell.titleLabel.text = job.title
        cell.descriptionLabel.text = job.description
        cell.locationLabel.text = job.location
        cell.datesLabel.text = job.dates
        
        return cell
    }
    
    // MARK: - Navigation Hand-Off
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showJobDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destinationVC = segue.destination as! JobDetailViewController
                let selectedJob = MockDatabase.jobs[indexPath.row]
                destinationVC.job = selectedJob
            }
        }
    }
}
