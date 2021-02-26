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
    @IBOutlet weak var manufacturerText: UITextView!
    @IBOutlet weak var sortText: UITextView!

    @IBOutlet weak var degreeText: UITextView!
    @IBOutlet weak var hoptypeText: UITextView!
    @IBOutlet weak var colorText: UITextView!
    
    @IBOutlet weak var extraFlavorText: UITextView!
    
    var info : QueryDocumentSnapshot?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if info == nil {
            print("error on segue")
        }
        else {
            titleLabel.text = info!.data()["title"] as? String
            sortText.text = alignText(text: "sort: ", offset: 14) + (info!.data()["sort"] as! String)
            manufacturerText.text = alignText(text: "manufacturer: ", offset: 14) + (info!.data()["manufacturer"] as! String)
            degreeText.text = String(format: "degree: %.1f", info!.data()["degree"] as! Double)
            hoptypeText.text = alignText(text: "hop type: ", offset: 14) + (info!.data()["hop_type"] as! String)
            colorText.text = alignText(text: "color: ", offset: 14) + (info!.data()["color"] as! String)
            extraFlavorText.text = alignText(text: "extra flavor: ", offset: 14) + (info!.data()["extra_flavor"] as! String)
            
            let url = info!.data()["avatar"] as? String
            Utils().downloadImage(from: URL(string: url!)!, image: avatarImageView)
        }
    }
    
    func alignText(text: String, offset: Int) -> String {
        let num = offset - text.count
        let spaces = String.init(repeating: "", count: num)
        return text + spaces
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "imageCollectionSegue"{
            let destVC = segue.destination as! ImageCollectionViewController
            destVC.photos = info!.data()["images"] as? Array<String>
            destVC.videos = info!.data()["videos"] as? Array<String>
        }
        if segue.identifier == "editSegue" {
            let destVC = segue.destination as! EditViewController
            destVC.beerProduct = info
        }
    }

}
