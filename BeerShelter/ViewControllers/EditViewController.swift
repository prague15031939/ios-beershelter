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
    @IBOutlet weak var sortTextField: UITextField!
    @IBOutlet weak var degreeTextField: UITextField!
    @IBOutlet weak var extraFlavorTextField: UITextField!
    @IBOutlet weak var colorTextField: UITextField!
    @IBOutlet weak var hopTypeTextField: UITextField!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var xTextField: UITextField!
    @IBOutlet weak var yTextField: UITextField!
    @IBOutlet weak var activityindicator: UIActivityIndicatorView!
    var imagePicker = UIImagePickerController()
    
    @IBOutlet weak var errorLabel: UILabel!
    
    var beerProduct : QueryDocumentSnapshot?
    
    required init?(coder: NSCoder) {
       super.init(coder: coder)
       NotificationCenter.default.addObserver(self, selector: #selector(self.settingsChanged), name: UserDefaults.didChangeNotification, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorLabel.alpha=0
        setDarkMode()
        setUpElements()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        beerAvatar.isUserInteractionEnabled = true
        beerAvatar.addGestureRecognizer(tapGestureRecognizer)
        activityindicator.alpha = 0
        
        titleTextField.text = beerProduct!.data()["title"] as? String
        manufacturerTextField.text = beerProduct!.data()["manufacturer"] as? String
        sortTextField.text = beerProduct!.data()["sort"] as? String
        degreeTextField.text = String(format: "%.1f", beerProduct!.data()["degree"] as! Double)
        extraFlavorTextField.text = beerProduct!.data()["extra_flavor"] as? String
        colorTextField.text = beerProduct!.data()["color"] as? String
        hopTypeTextField.text = beerProduct!.data()["hop_type"] as? String
        xTextField.text = String(format: "%.4f", (beerProduct!.data()["latitude"] as? Double)!)
        yTextField.text = String(format: "%.4f", (beerProduct!.data()["longitude"] as? Double)!)
        let url = beerProduct!.data()["avatar"] as? String
        Utils().downloadImage(from: URL(string: url!)!, image: beerAvatar, completion: {_ in })
    }
    
    @objc func settingsChanged(){
        setDarkMode()
        setUpElements()
    }
    
    @IBAction func editTouched(_ sender: Any) {
        activityindicator.alpha=1
        activityindicator.startAnimating()
        
        let error = validateFields()
        if error == nil {
            let title = titleTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let manufacturer = manufacturerTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let sort = sortTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let degree = Double(degreeTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines))
            let color = colorTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let extraFlavor = extraFlavorTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let hopType = hopTypeTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let x = Double(xTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines))
            let y = Double(yTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines))

            let avatar = beerProduct!.data()["avatar"] as! String
            updateCharacter(title, manufacturer: manufacturer, sort: sort, color: color, extraFlavor: extraFlavor, hopType: hopType, degree: degree!, avatar: avatar, x: x!, y: y!, documentID: beerProduct!.documentID)
        }
        else{
            styleUtils.showError(error!, label: self.errorLabel)
            activityindicator.alpha=0
            activityindicator.stopAnimating()
        }
    }
    
    func updateCharacter(_ title: String, manufacturer: String, sort: String, color: String, extraFlavor: String, hopType: String, degree: Double, avatar: String, x: Double, y: Double, documentID: String){
        
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
                    "title": title, "manufacturer": manufacturer, "latitude": x,"longitude": y, "avatar": newAvatar, "sort": sort, "degree": degree, "color": color, "hop_type": hopType, "extra_flavor": extraFlavor
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
    
    func setDarkMode(){
        if (UserDefaults.standard.bool(forKey: "DarkMode") == false){
            overrideUserInterfaceStyle = .light
        }
        else{
            overrideUserInterfaceStyle = .dark
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
        if titleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)=="" || manufacturerTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)=="" ||
            sortTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)=="" ||
            colorTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)=="" ||
            degreeTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)=="" ||
            extraFlavorTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)=="" ||
            hopTypeTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)=="" ||
            xTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)=="" ||
            yTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)==""
            {
                return NSLocalizedString("EditVC_notFullError", comment: "")
            }
        
        let x = Double((xTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines))!)
        let y = Double((yTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines))!)
        let degree = Double((degreeTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines))!)
        if  (x == nil || x! < -89.3 || x! > 89.3) ||  (y == nil || y! < -89.3 || y! > 89.3){
            return NSLocalizedString("EditVC_coordsNotDouble", comment: "")
        }
        if degree == nil || degree! < 0.5 || degree! > 99.9 {
            return NSLocalizedString("EditVC_degreeNotDouble", comment: "")
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
    
    func setUpElements(){
        styleUtils.styleActivityIndicator(activityindicator)
        editButton.layer.cornerRadius = 5
        editButton.setTitle(NSLocalizedString("EditVC_editButton", comment: ""), for: .normal)
    }

}
