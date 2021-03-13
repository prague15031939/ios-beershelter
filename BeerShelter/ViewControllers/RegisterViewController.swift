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
    @IBOutlet weak var registerLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var regButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupElements()
        setLocalization()
    }
    
    @IBAction func signupTouched(_ sender: Any) {
        if validateFields() != nil {
            styleUtils.showError(NSLocalizedString("RegisterVC_invalidData", comment: ""), label: self.errorLabel)
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
                    if querySnapshot!.documents.count != 0 {
                        styleUtils.showError(NSLocalizedString("RegisterVC_UserError", comment: ""), label: self.errorLabel)
                    }
                    else {
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
            return "error"
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
    
    func setLocalization(){
        registerLabel.text=NSLocalizedString("RegisterVC_registerLabel", comment: "")
        regButton.setTitle(NSLocalizedString("RegisterVC_regButton", comment: ""), for: .normal)
        usernameTextField.placeholder=NSLocalizedString("RegisterVC_usernameTextField", comment: "")
        emailTextField.placeholder=NSLocalizedString("RegisterVC_emailTextField", comment: "")
        passwordTextField.placeholder=NSLocalizedString("RegisterVC_passwordTextField", comment: "")
    }
    
    func setupElements() {
        errorLabel.alpha = 0
        errorLabel.textColor = UIColor.black
        registerLabel.textColor = UIColor.black
        usernameTextField.layer.borderWidth = 1
        emailTextField.layer.borderWidth = 1
        passwordTextField.layer.borderWidth = 1
        emailTextField.layer.borderWidth = 1
        usernameTextField.layer.cornerRadius = 5
        emailTextField.layer.cornerRadius = 5
        passwordTextField.layer.cornerRadius = 5
        usernameTextField.layer.borderColor = UIColor.black.cgColor
        emailTextField.layer.borderColor = UIColor.black.cgColor
        passwordTextField.layer.borderColor = UIColor.black.cgColor
        usernameTextField.backgroundColor = UIColor.white
        emailTextField.backgroundColor = UIColor.white
        passwordTextField.backgroundColor = UIColor.white
        usernameTextField.textColor = UIColor.black
        emailTextField.textColor = UIColor.black
        passwordTextField.textColor = UIColor.black
        usernameTextField.attributedPlaceholder = NSAttributedString(string: "username", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        emailTextField.attributedPlaceholder = NSAttributedString(string: "email", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        regButton.layer.cornerRadius = 5
        regButton.backgroundColor = UIColor.black
        regButton.layer.cornerRadius = 5
    }
}
