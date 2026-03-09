import UIKit

// mock data model
struct JobRequest {
    let id: String
    let title: String
    let description: String
    let location: String
    let dates: String
}

// global dummy data
class MockDatabase {
    static let jobs: [JobRequest] = [
        JobRequest(id: "1", title: "Dog Sitting for Luna", description: "Needs a morning walk.", location: "Seattle, WA", dates: "March 12-14"),
        JobRequest(id: "2", title: "Weekend cat feeding", description: "Feed Apollo twice a day.", location: "Bellevue, WA", dates: "March 20-22"),
        JobRequest(id: "3", title: "Puppy daycare", description: "Watch my golden retriever puppy.", location: "Kirkland, WA", dates: "March 25")
    ]
}


class FeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    // MARK: - Table View Functions
    
    // find out how many rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MockDatabase.jobs.count
    }
    
    // fill out rows
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "JobCell", for: indexPath) as! JobCell
        
        let job = MockDatabase.jobs[indexPath.row]
        
        cell.titleLabel.text = job.title
        cell.descriptionLabel.text = job.description
        cell.locationLabel.text = job.location
        cell.datesLabel.text = job.dates
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // check for specific bridge
        if segue.identifier == "showJobDetail" {
            
            // identify row user tapped
            if let indexPath = tableView.indexPathForSelectedRow {
                
                // get destination screen and cast it to custom class
                let destinationVC = segue.destination as! JobDetailViewController
                
                // get correct job from mock db using
                let selectedJob = MockDatabase.jobs[indexPath.row]
                
                // hand data to destination
                destinationVC.job = selectedJob
            }
        }
    }
}
