//
//  ViewController.swift
//  BeerShelter
//
//  Created by NASTUSYA on 2/23/21.
//

import UIKit
import FirebaseFirestore
import CryptoKit

class LoginViewController: UIViewController {
    var db = Firestore.firestore()
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var logButton: UIButton!
    @IBOutlet weak var regButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBAction func logTouched(_ sender: Any) {
        let username = usernameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        db.collection("user").whereField("username", isEqualTo: username)
            .getDocuments() { [self] (querySnapshot, err) in
                if let err = err {
                    print(err)
                } else {
                    if querySnapshot!.documents.count == 0 {
                        Utils().showError("user does not exist", label: self.errorLabel)
                    }
                    else {
                        for document in querySnapshot!.documents {
                            let data = document.data()["password_hash"] as! String
                            if data == Utils().getHash(data: password) {
                                print("\(data)")
                                self.transitionToTable()
                            }
                            else {
                                Utils().showError("invalid password", label: self.errorLabel)
                            }
                        }
                    }
                }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorLabel.alpha = 0
        regButton.backgroundColor = .clear
        regButton.layer.borderWidth = 2
        regButton.layer.borderColor = UIColor.black.cgColor
        regButton.layer.cornerRadius = 5
        logButton.layer.cornerRadius = 5
    }

    func transitionToTable() {
            
        let tableViewController = (storyboard?.instantiateViewController(identifier: "tableVC") as? TableViewController)!
        let navViewController = storyboard?.instantiateViewController(identifier: "navVC") as? UINavigationController
        navViewController?.pushViewController(tableViewController, animated: true)
        view.window?.rootViewController = navViewController
        view.window?.makeKeyAndVisible()
            
    }

}


