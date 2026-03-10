//
//  ViewController.swift
//  petpal
//
//  Created by Owen Wong on 3/8/26.
//

import UIKit

struct LoginPayload: Codable {
    let username: String
    let password: String
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func user1Tapped(_ sender: Any) {
        attemptLogin(username: "User 1", password: "password123")
    }
    
    @IBAction func user2Tapped(_ sender: Any) {
        attemptLogin(username: "User 2", password: "password123")
    }
    
    func attemptLogin(username: String, password: String) {
        guard let url = URL(string: "https://petpal-acd6.onrender.com/login") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let payload = LoginPayload(username: username, password: password)
        request.httpBody = try? JSONEncoder().encode(payload)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error: \(error)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let data = data {
                DispatchQueue.main.async {
                    do {
                        let loggedInUser = try JSONDecoder().decode(UserResponse.self, from: data)
                        SessionManager.shared.currentUser = loggedInUser
                        print("SUCCESS: Logged in as \(loggedInUser.username) with ID: \(loggedInUser._id)")
                        
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "loginSegue", sender: nil)
                        }
                    } catch {
                        print("Failed to decode user data: \(error)")
                    }
                }
            } else {
                print("Login failed. Check your backend logs.")
            }
        }.resume()
    }
}

