//
//  RegisterViewController.swift
//  BeerShelter
//
//  Created by NASTUSYA on 2/26/21.
//

import UIKit
import FirebaseFirestore

class RegisterViewController: UIViewController {
    var db = Firestore.firestore()
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var regButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        regButton.layer.cornerRadius = 5
    }
    @IBAction func signupTouched(_ sender: Any) {
        if validateFields() != nil {
            return
        }
        
        let username = usernameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        db.collection("user").whereField("username", isEqualTo: username)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    if querySnapshot!.documents.count == 0 {
                    
                        self.db.collection("user").addDocument(data: ["username": username, "email": email, "password_hash": Utils().getHash(data: password)]) { [self] (error) in
                    
                                if error == nil {
                                    transitionToTable()
                            }
                        }
                    }
                }
            }
    }
    
    
    func validateFields() -> String? {
        if usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)=="" || emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)=="" ||
        passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)==""
        {
            return NSLocalizedString( "SignUpViewController_notFullError", comment: "")
        }
        
        return nil
    }
    
    func transitionToTable() {
        
        let tableViewController = (storyboard?.instantiateViewController(identifier: "tableVC") as? TableViewController)!
        let navViewController = storyboard?.instantiateViewController(identifier: "navVC") as? UINavigationController
        navViewController?.pushViewController(tableViewController, animated: true)
        view.window?.rootViewController = navViewController
        view.window?.makeKeyAndVisible()
        
    }
}
