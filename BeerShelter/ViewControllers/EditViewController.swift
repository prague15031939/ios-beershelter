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
    var imagePicker = UIImagePickerController()
    
    var beerProduct : QueryDocumentSnapshot?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        beerAvatar.isUserInteractionEnabled = true
        beerAvatar.addGestureRecognizer(tapGestureRecognizer)

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

}
