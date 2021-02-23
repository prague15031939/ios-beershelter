//
//  ViewController.swift
//  BeerShelter
//
//  Created by NASTUSYA on 2/23/21.
//

import UIKit
import FirebaseFirestore

class LoginViewController: UIViewController {
    var db = Firestore.firestore()
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var logButton: UIButton!
    
    @IBAction func logTouched(_ sender: Any) {
        let username = usernameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        db.collection("user").whereField("username", isEqualTo: username)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        let data = document.data()["password_hash"] as! String
                        if data == password {
                            print("\(data)");
                        }
                    }
                }
        }
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

