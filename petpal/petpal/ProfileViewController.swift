//
//  ProfileViewController.swift
//  petpal
//
//  Created by Owen Wong on 3/9/26.
//

import UIKit

class ProfileViewController: UIViewController {
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var headlineLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var contactInfoLabel: UILabel!
    
    var userToShow: UserResponse?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let user = SessionManager.shared.currentUser {
            usernameLabel.text = user.username
            headlineLabel.text = user.headline ?? "No headline set"
            locationLabel.text = user.location ?? "Location unknown"
            bioLabel.text = user.bio ?? "No bio available"
            contactInfoLabel.text = "Contact: \(user.contactInfo ?? "N/A")"
            
        } else {
            usernameLabel.text = "Error: User not found"
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
