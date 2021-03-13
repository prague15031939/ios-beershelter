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
    
    required init?(coder: NSCoder) {
       super.init(coder: coder)
       NotificationCenter.default.addObserver(self, selector: #selector(self.settingsChanged), name: UserDefaults.didChangeNotification, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupElements()
        setDarkMode()
        
        if info == nil {
            print("error on segue")
        }
        else {
            titleLabel.text = info!.data()["title"] as? String
            sortText.text = alignText(text: NSLocalizedString("DetailVC_sortText", comment: ""), offset: 20) + (info!.data()["sort"] as! String)
            manufacturerText.text = alignText(text: NSLocalizedString("DetailVC_manufacturerText", comment: ""), offset: 20) + (info!.data()["manufacturer"] as! String)
            degreeText.text = String(format: NSLocalizedString("DetailVC_degreeText", comment: "")+"%.1f", info!.data()["degree"] as! Double)
            hoptypeText.text = alignText(text: NSLocalizedString("DetailVC_hoptypeText", comment: ""), offset: 20) + (info!.data()["hop_type"] as! String)
            colorText.text = alignText(text: NSLocalizedString("DetailVC_colorText", comment: ""), offset: 20) + (info!.data()["color"] as! String)
            extraFlavorText.text = alignText(text: NSLocalizedString("DetailVC_extraFlavorText", comment: ""), offset: 20) + (info!.data()["extra_flavor"] as! String)
            
            let url = info!.data()["avatar"] as? String
            Utils().downloadImage(from: URL(string: url!)!, image: avatarImageView, completion: {_ in })
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
    
    func setDarkMode(){
        if (UserDefaults.standard.bool(forKey: "DarkMode") == false){
            overrideUserInterfaceStyle = .light
        }
        else{
            overrideUserInterfaceStyle = .dark
        }
    }
    
    @objc func settingsChanged(){
        setupElements()
        setDarkMode()
    }
    
    func setupElements() {
        styleUtils.styleLabel(titleLabel)
        styleUtils.styleTextView(manufacturerText)
        styleUtils.styleTextView(sortText)
        styleUtils.styleTextView(degreeText)
        styleUtils.styleTextView(extraFlavorText)
        styleUtils.styleTextView(hoptypeText)
        styleUtils.styleTextView(colorText)
    }

}
