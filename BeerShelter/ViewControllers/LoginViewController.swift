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
    @IBOutlet weak var loginLabel: UILabel!
    
    
    @IBAction func logTouched(_ sender: Any) {
        let username = usernameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        db.collection("user").whereField("username", isEqualTo: username)
            .getDocuments() { [self] (querySnapshot, err) in
                if let err = err {
                    print(err)
                } else {
                    if querySnapshot!.documents.count == 0 {
                        styleUtils.showError(NSLocalizedString("LoginVC_UserError", comment: ""), label: self.errorLabel)
                    }
                    else {
                        for document in querySnapshot!.documents {
                            let data = document.data()["password_hash"] as! String
                            if data == Utils().getHash(data: password) {
                                print("\(data)")
                                self.transitionToTable()
                            }
                            else {
                                styleUtils.showError(NSLocalizedString("LoginVC_UserError", comment: ""), label: self.errorLabel)
                            }
                        }
                    }
                }
        }
        
    }
    
    required init?(coder: NSCoder) {
       super.init(coder: coder)
       NotificationCenter.default.addObserver(self, selector: #selector(self.settingsChanged), name: UserDefaults.didChangeNotification, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupElements()
        setLocalization()
    }

    func transitionToTable() {
            
        let tableViewController = (storyboard?.instantiateViewController(identifier: "tableVC") as? TableViewController)!
        let navViewController = storyboard?.instantiateViewController(identifier: "navVC") as? UINavigationController
        navViewController?.pushViewController(tableViewController, animated: true)
        view.window?.rootViewController = navViewController
        view.window?.makeKeyAndVisible()
            
    }
    
    func setupElements() {
        errorLabel.alpha = 0
        errorLabel.textColor = UIColor.black
        loginLabel.textColor = UIColor.black
        usernameTextField.layer.borderWidth = 1
        passwordTextField.layer.borderWidth = 1
        usernameTextField.layer.cornerRadius = 5
        passwordTextField.layer.cornerRadius = 5
        usernameTextField.layer.borderColor = UIColor.black.cgColor
        passwordTextField.layer.borderColor = UIColor.black.cgColor
        usernameTextField.backgroundColor = UIColor.white
        passwordTextField.backgroundColor = UIColor.white
        usernameTextField.textColor = UIColor.black
        passwordTextField.textColor = UIColor.black
        usernameTextField.attributedPlaceholder = NSAttributedString(string: "username", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        regButton.backgroundColor = .clear
        regButton.layer.borderWidth = 2
        regButton.layer.borderColor = UIColor.black.cgColor
        regButton.layer.cornerRadius = 5
        regButton.setTitleColor(UIColor.black, for: .normal)
        logButton.layer.cornerRadius = 5
    }
    
    func setLocalization(){
        loginLabel.text=NSLocalizedString("LoginVC_loginLabel", comment: "")
        logButton.setTitle(NSLocalizedString("LoginVC_logButton", comment: ""), for: .normal)
        regButton.setTitle(NSLocalizedString("LoginVC_regButton", comment: ""), for: .normal)
        usernameTextField.placeholder=NSLocalizedString("LoginVC_usernameTextField", comment: "")
        passwordTextField.placeholder=NSLocalizedString("LoginVC_passwordTextField", comment: "")
    }
    
    @objc func settingsChanged(){
       setLocalization()
    }

}


