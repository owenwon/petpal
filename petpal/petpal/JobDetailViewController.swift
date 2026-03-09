//
//  JobDetailViewController.swift
//  petpal
//
//  Created by Owen Wong on 3/8/26.
//

import UIKit

class JobDetailViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var datesLabel: UILabel!
    
    var job: JobRequest?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let selectedJob = job {
            titleLabel.text = selectedJob.title
            descriptionLabel.text = selectedJob.description
            locationLabel.text = selectedJob.location
            datesLabel.text = selectedJob.dates
        }
        // Do any additional setup after loading the view.
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
