//
//  BeerInfoViewController.swift
//  BeerShelter
//
//  Created by NASTUSYA on 2/24/21.
//

import UIKit
import Firebase

class BeerInfoViewController: UIViewController {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var sortLabel: UILabel!
    var info : QueryDocumentSnapshot?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if info == nil {
            print("error on segue")
        }
        else {
            titleLabel.text = info!.data()["title"] as? String
            sortLabel.text = info!.data()["sort"] as? String
            
            let url = info!.data()["avatar"] as? String
            downloadImage(from: URL(string: url!)!, image: avatarImageView)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "imageCollectionSegue"{
            let destVC = segue.destination as! ImageCollectionViewController
            destVC.photos = info!.data()["images"] as? Array<String>
        }
    }

}
