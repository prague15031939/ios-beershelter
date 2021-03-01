//
//  EditViewController.swift
//  BeerShelter
//
//  Created by NASTUSYA on 2/25/21.
//

import UIKit
import Firebase

class EditViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var beerAvatar: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var manufacturerTextField: UITextField!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var xTextField: UITextField!
    @IBOutlet weak var yTextField: UITextField!
    @IBOutlet weak var activityindicator: UIActivityIndicatorView!
    var imagePicker = UIImagePickerController()
    
    var beerProduct : QueryDocumentSnapshot?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        editButton.layer.cornerRadius = 5
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        beerAvatar.isUserInteractionEnabled = true
        beerAvatar.addGestureRecognizer(tapGestureRecognizer)
        activityindicator.alpha = 0
        
        titleTextField.text = beerProduct!.data()["title"] as? String
        manufacturerTextField.text = beerProduct!.data()["manufacturer"] as? String
        xTextField.text = String(format: "%.4f", (beerProduct!.data()["latitude"] as? Double)!)
        yTextField.text = String(format: "%.4f", (beerProduct!.data()["longitude"] as? Double)!)
        let url = beerProduct!.data()["avatar"] as? String
        Utils().downloadImage(from: URL(string: url!)!, image: beerAvatar, completion: {_ in })
    }
    
    @IBAction func editTouched(_ sender: Any) {
        activityindicator.alpha=1
        activityindicator.startAnimating()
        
        let error = validateFields()
        if error == nil {
            let title = titleTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let manufacturer = manufacturerTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let x = Double(xTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines))
            let y = Double(yTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines))

            let avatar = beerProduct!.data()["avatar"] as! String
            updateCharacter(title, manufacturer: manufacturer, avatar: avatar, x: x!, y: y!, documentID: beerProduct!.documentID)
        }
        else{
            activityindicator.alpha=0
            activityindicator.stopAnimating()
        }
    }
    
    func updateCharacter(_ title: String, manufacturer: String, avatar: String, x: Double, y: Double, documentID: String){
        
        Utils().uploadPhoto(beerAvatar) {(completion) in
             if completion == nil {
                 self.activityindicator.alpha=0
                 self.activityindicator.stopAnimating()
             }
             else {
                //Utils().deleteDocument(avatar)
                let newAvatar = completion!.absoluteString
                
                let db = Firestore.firestore()
                let ref = db.collection("beer_product").document(documentID)
                ref.updateData([
                    "title": title, "manufacturer": manufacturer, "latitude": x,"longitude": y, "avatar": newAvatar
                ]) { [self] (error) in
                    if error != nil {
                        self.activityindicator.alpha=0
                        activityindicator.stopAnimating()
                    }
                    else{
                        self.transitionToTable()              }
                }
             }
        }
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = false
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            self.dismiss(animated: true, completion: { () -> Void in
                if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                        self.beerAvatar.image = image
                    }
                })
        }
    
    func validateFields() -> String? {
        if titleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)=="" || manufacturerTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)=="" /*||
            ageTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)=="" ||
            seasonTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)=="" ||
            xTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)=="" ||
            yTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)==""*/
            {
                return NSLocalizedString("SignUpViewController_notFullError", comment: "")
            }
        
        let x = Double((xTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines))!)
        let y = Double((yTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines))!)
        if  (x == nil || x! < -89.3 || x! > 89.3) ||  (y == nil || y! < -89.3 || y! > 89.3){
            return NSLocalizedString("CharacterEditViewController_coordsNotDouble", comment: "")
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
