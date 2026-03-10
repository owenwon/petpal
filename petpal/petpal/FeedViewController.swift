import UIKit

struct JobRequest: Codable {
    let _id: String
    let ownerId: String
    let ownerName: String
    let title: String
    let petName: String
    let description: String
    let price: Int
    let dates: String
    let status: String
}



class FeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var jobs: [JobRequest] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        fetchJobs()
    }
    
    func fetchJobs() {
        guard let url = URL(string: "https://petpal-acd6.onrender.com/requests") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching live jobs: \(error)")
                return
            }
            
            if let data = data {
                do {
                    let liveJobs = try JSONDecoder().decode([JobRequest].self, from: data)
                    
                    self.jobs = liveJobs
                    print("SUCCESS: Downloaded \(self.jobs.count) live jobs!")
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                } catch {
                    print("Failed to decode live jobs: \(error)")
                }
            }
        }.resume()
        }
        
        // MARK: - Table View Functions
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return jobs.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "JobCell", for: indexPath) as! JobCell
            
            let job = jobs[indexPath.row]
            
            cell.titleLabel.text = job.title
            cell.descriptionLabel.text = job.description
            cell.datesLabel.text = job.dates
            
            cell.locationLabel.text = "$\(job.price)/day • For \(job.petName)"
            
            return cell
        }
        
        // MARK: - Navigation Hand-Off
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "showJobDetail" {
                if let indexPath = tableView.indexPathForSelectedRow {
                    let destinationVC = segue.destination as! JobDetailViewController
                    let selectedJob = jobs[indexPath.row]
                    destinationVC.job = selectedJob
                }
            }
        }
}
