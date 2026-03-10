//
//  JobDetailViewController.swift
//  petpal
//
//  Created by Owen Wong on 3/8/26.
//

import UIKit

struct ApplicationPayload: Codable {
    let requestId: String
    let sitterId: String
    let sitterName: String
}

class JobDetailViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var datesLabel: UILabel!
    
    @IBOutlet weak var applyButton: UIButton!
    
    var job: JobRequest?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let selectedJob = job {
            titleLabel.text = selectedJob.title
            descriptionLabel.text = selectedJob.description
            locationLabel.text = "$\(selectedJob.price) per day"
            datesLabel.text = selectedJob.dates
            
            if let currentUser = SessionManager.shared.currentUser {
                if selectedJob.ownerId == currentUser._id {
                    applyButton.setTitle("View Applicants", for: .normal)
                    applyButton.backgroundColor = .systemBlue
                    applyButton.isEnabled = true
                }
            }
        }
        // Do any additional setup after loading the view.
    }
    

    @IBAction func applyButtonTapped(_ sender: Any) {
        guard let selectedJob = job, let currentUser = SessionManager.shared.currentUser else { return }
        
        if selectedJob.ownerId == currentUser._id {
            self.performSegue(withIdentifier: "showApplicants", sender: nil)
            return
        }
                
        
        applyButton.isEnabled = false
        applyButton.setTitle("Applying...", for: .normal)
        
        let payload = ApplicationPayload(
            requestId: selectedJob._id,
            sitterId: currentUser._id,
            sitterName: currentUser.username
        )
        
        guard let url = URL(string: "https://petpal-acd6.onrender.com/applications") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(payload)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            DispatchQueue.main.async {
                if let httpResponse = response as? HTTPURLResponse {
                    
                    if httpResponse.statusCode == 201 {
                        self.applyButton.setTitle("Applied Successfully!", for: .normal)
                        self.applyButton.backgroundColor = .systemGreen
                        
                    } else if httpResponse.statusCode == 400 {
                        self.applyButton.setTitle("Already Applied", for: .normal)
                        self.applyButton.backgroundColor = .lightGray
                        
                    } else {
                        self.applyButton.setTitle("Error. Try Again", for: .normal)
                        self.applyButton.isEnabled = true
                    }
                }
            }
        }.resume()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
