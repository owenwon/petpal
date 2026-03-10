//
//  MyAccountViewController.swift
//  petpal
//
//  Created by Owen Wong on 3/8/26.
//

import UIKit

struct ApplicationResponse: Codable {
    let _id: String
    let requestId: String
    let requestTitle: String?
    let ownerName: String?
    let ownerId: String?
    let sitterId: String?
    let sitterName: String?
    let status: String
}

class MyAccountViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    var postedJobs: [JobRequest] = []
    var myApplications: [ApplicationResponse] = []
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        tableView.reloadData()
        
        if sender.selectedSegmentIndex == 0 {
            fetchMyPostedJobs()
        } else {
            fetchMyApplications()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        fetchMyPostedJobs()
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        if identifier == "showJobDetail" && segmentedControl.selectedSegmentIndex == 1 {
            return false
        }
        
        return true
    }

    // MARK: - Network Calls
    func fetchMyPostedJobs() {
        guard let currentUser = SessionManager.shared.currentUser else { return }
        guard let url = URL(string: "https://petpal-acd6.onrender.com/requests/owner/\(currentUser._id)") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    self.postedJobs = try JSONDecoder().decode([JobRequest].self, from: data)
                    DispatchQueue.main.async { self.tableView.reloadData() }
                } catch { print("Failed to decode posts: \(error)") }
            }
        }.resume()
    }
    
    func fetchMyApplications() {
        guard let currentUser = SessionManager.shared.currentUser else { return }
        guard let url = URL(string: "https://petpal-acd6.onrender.com/applications/sitter/\(currentUser._id)") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    self.myApplications = try JSONDecoder().decode([ApplicationResponse].self, from: data)
                    DispatchQueue.main.async { self.tableView.reloadData() }
                } catch { print("Failed to decode applications: \(error)") }
            }
        }.resume()
    }
    
    // MARK: - Table View Functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if segmentedControl.selectedSegmentIndex == 0 {
            return postedJobs.count
        } else {
            return myApplications.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "JobCell", for: indexPath) as! JobCell
        
        if segmentedControl.selectedSegmentIndex == 0 {
            let job = postedJobs[indexPath.row]
            cell.titleLabel.text = job.title
            cell.descriptionLabel.text = job.description
            cell.datesLabel.text = job.dates
            cell.locationLabel.text = "$\(job.price)/day • For \(job.petName)"
        } else {
            let app = myApplications[indexPath.row]
            cell.titleLabel.text = app.requestTitle ?? "Unknown Job"
            cell.descriptionLabel.text = "Status: \(app.status.uppercased())"
            cell.datesLabel.text = ""
            cell.locationLabel.text = "Owner: \(app.ownerName ?? "Unknown")"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if segmentedControl.selectedSegmentIndex == 1 {
            let app = myApplications[indexPath.row]
            
            if app.status == "approved" {
                guard let ownerId = app.ownerId else { return }
                
                guard let url = URL(string: "https://petpal-acd6.onrender.com/users/\(ownerId)") else { return }
                
                URLSession.shared.dataTask(with: url) { data, response, error in
                    if let data = data {
                        DispatchQueue.main.async {
                            do {
                                let ownerProfile = try JSONDecoder().decode(UserResponse.self, from: data)
                                self.performSegue(withIdentifier: "showMatchProfile", sender: ownerProfile)
                                
                            } catch { print("Failed to decode owner: \(error)") }
                        }
                    }
                }.resume()
                
            } else if app.status == "rejected" {
                let alert = UIAlertController(title: "Application Rejected", message: "The owner went with another sitter for this job.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
                
            } else {
                let alert = UIAlertController(title: "Application Pending", message: "The owner hasn't accepted your application yet.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
        }
    }
    
    // MARK: - Navigation Hand-Off
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showJobDetail" {
            if segmentedControl.selectedSegmentIndex == 0,
               let indexPath = tableView.indexPathForSelectedRow {
                let destinationVC = segue.destination as! JobDetailViewController
                destinationVC.job = postedJobs[indexPath.row]
            }
        } else if segue.identifier == "showMatchProfile" {
            let destinationVC = segue.destination as! ProfileViewController
            if let matchedUser = sender as? UserResponse {
                destinationVC.userToShow = matchedUser
                destinationVC.isMatch = true
            }
        }
    }
}
