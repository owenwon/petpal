//
//  CreateJobViewController.swift
//  petpal
//
//  Created by Owen Wong on 3/8/26.
//

import UIKit

struct CreateJobPayload: Codable {
    let ownerId: String
    let ownerName: String
    let title: String
    let petName: String
    let description: String
    let price: Int
    let dates: String
}

class CreateJobViewController: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var petNameTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var datesTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func postJobTapped(_ sender: Any) {
        guard let currentUser = SessionManager.shared.currentUser else {
            print("Error: No user is currently logged in!")
            return
        }
        
        let title = titleTextField.text ?? ""
        let petName = petNameTextField.text ?? ""
        let description = descriptionTextField.text ?? ""
        let dates = datesTextField.text ?? ""
        
        let price = Int(priceTextField.text ?? "0") ?? 0
        
        let payload = CreateJobPayload(
            ownerId: currentUser._id,
            ownerName: currentUser.username,
            title: title,
            petName: petName,
            description: description,
            price: price,
            dates: dates
        )
        
        guard let url = URL(string: "https://petpal-acd6.onrender.com/requests") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(payload)
        } catch {
            print("Failed to encode job: \(error)")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error: \(error)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 {
                print("SUCCESS: Job saved to live MongoDB!")
                
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            } else {
                print("Server rejected the request. Check your backend logs.")
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
