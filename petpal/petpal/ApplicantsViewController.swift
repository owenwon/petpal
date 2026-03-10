//
//  ApplicantsViewController.swift
//  petpal
//
//  Created by Owen Wong on 3/10/26.
//

import UIKit

class ApplicantsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var jobId: String?
    
    var applicants: [ApplicationResponse] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        // Do any additional setup after loading the view.
        fetchApplicants()
    }
    
    func fetchApplicants() {
        guard let id = jobId else { return }
        guard let url = URL(string: "https://petpal-acd6.onrender.com/requests/\(id)/applicants") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    self.applicants = try JSONDecoder().decode([ApplicationResponse].self, from: data)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                } catch { print("Failed to decode applicants: \(error)") }
            }
        }.resume()
    }
    
    struct StatusUpdatePayload: Codable {
        let status: String
    }
    
    func updateApplicationStatus(application: ApplicationResponse, newStatus: String) {
        guard let url = URL(string: "https://petpal-acd6.onrender.com/applications/\(application._id)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let payload = StatusUpdatePayload(status: newStatus)
        request.httpBody = try? JSONEncoder().encode(payload)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    print("SUCCESS: Application marked as \(newStatus)!")
                    
                    self.fetchApplicants()
                    
                    if newStatus == "approved", let sitterId = application.sitterId {
                        self.fetchAndShowSitter(sitterId: sitterId)
                    }
                } else {
                    print("Failed to update status.")
                }
            }
        }.resume()
    }
    
    func fetchAndShowSitter(sitterId: String) {
        guard let url = URL(string: "https://petpal-acd6.onrender.com/users/\(sitterId)") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let sitterProfile = try JSONDecoder().decode(UserResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "showSitterProfile", sender: sitterProfile)
                    }
                } catch { print("Failed to decode sitter: \(error)") }
            }
        }.resume()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return applicants.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ApplicantCell", for: indexPath) as! ApplicantCell
        
        let applicant = applicants[indexPath.row]
        
        cell.nameLabel.text = applicant.sitterName ?? "Unknown Sitter"
        
        if applicant.status == "approved" {
            cell.acceptButton.setTitle("Approved", for: .normal)
            cell.acceptButton.isEnabled = false
            cell.rejectButton.isHidden = true
        } else if applicant.status == "rejected" {
            cell.rejectButton.setTitle("Rejected", for: .normal)
            cell.rejectButton.isEnabled = false
            cell.acceptButton.isHidden = true
        }
        
        cell.acceptAction = {
            self.updateApplicationStatus(application: applicant, newStatus: "approved")
        }
        
        cell.rejectAction = {
            self.updateApplicationStatus(application: applicant, newStatus: "rejected")
        }
        
        return cell
    }
    

    
    // MARK: - Navigation

     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSitterProfile" {
             let destinationVC = segue.destination as! ProfileViewController
             if let sitter = sender as? UserResponse {
                 destinationVC.userToShow = sitter
                 destinationVC.isMatch = true
             }
         }
     }
    
    

}
