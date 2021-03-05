//
//  tableViewController.swift
//  BeerShelter
//
//  Created by NASTUSYA on 2/23/21.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage
import FirebaseUI

class TableViewController: UIViewController {

    @IBOutlet weak var beerTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var beerList = Array<QueryDocumentSnapshot>()
    var viewBeerList = Array<QueryDocumentSnapshot>()
    var beerImages : [String: UIImage] = [:]
    
    required init?(coder: NSCoder) {
       super.init(coder: coder)
       NotificationCenter.default.addObserver(self, selector: #selector(self.settingsChanged), name: UserDefaults.didChangeNotification, object: nil)
    }
    
    @IBAction func settingsTapped(_ sender: Any) {
        let tableViewController = (storyboard?.instantiateViewController(identifier: "tableVC") as? TableViewController)!
        let navViewController = storyboard?.instantiateViewController(identifier: "navVC") as? UINavigationController
        navViewController?.pushViewController(tableViewController, animated: true)
               view.window?.rootViewController = navViewController
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                print("Settings opened: \(success)") 
            })
        }
               
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.alpha=1
        activityIndicator.startAnimating()
        
        loadBeerItems() { [self] (completion) in
            if completion == nil {
                print("Error loading characters")
            }
            else{
                self.beerList = completion!
                self.viewBeerList = self.beerList
                self.beerTableView.reloadData()
                
                self.activityIndicator.stopAnimating()
                self.activityIndicator.alpha = 0
            }
                
        }
        
        searchBar.delegate = self
        beerTableView.delegate = self
        beerTableView.dataSource = self
    }
    
    func loadBeerItems(completion: @escaping (Array<QueryDocumentSnapshot>?) -> Void){

        let db = Firestore.firestore()
        db.collection("beer_product").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                completion(nil)
            } else {
                completion(querySnapshot!.documents)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailSegue"{
            if let indexPath = beerTableView.indexPathForSelectedRow{
                let destVC = segue.destination as! BeerInfoViewController
                destVC.info = viewBeerList[indexPath.row]
            }
        }
        if segue.identifier == "mapSegue" {
            let destVC = segue.destination as! MapViewController
            destVC.beerList = beerList
        }
    }
    
    func getItemsByText(text: String, src: Array<QueryDocumentSnapshot>) {
        viewBeerList.removeAll()
        for item in src {
            if (item.data()["title"] as! String).lowercased().contains(text.lowercased()) || (item.data()["manufacturer"] as! String).lowercased().contains(text.lowercased()) {
                viewBeerList.append(item)
            }
        }
    }
}

extension TableViewController : UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !searchText.isEmpty && searchText.count >= 3 {
            getItemsByText(text: searchText, src: beerList)
            beerTableView.reloadData()
        }
        else if (searchText.isEmpty) {
            viewBeerList = beerList
            beerTableView.reloadData()
        }
    }
}

extension TableViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewBeerList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath) as! CustomTableViewCell
        let font=UserDefaults.standard.string(forKey: "fontStyle")
        let size=UserDefaults.standard.integer(forKey: "fontSize")
        Utils().styleLabel(cell.titleLabel, fontName: font!, fontSize: size)
        cell.beerImageView.image = UIImage(systemName: "photo.on.rectangle")
        //if indexPath.row % 2 == 1 {
        //    cell.backgroundColor = UIColor.opaqueSeparator
        //}
        cell.titleLabel.text = viewBeerList[indexPath.row].data()["title"] as? String
        cell.sortLabel.text = "sort: " + (viewBeerList[indexPath.row].data()["sort"] as! String)
        cell.manufacturerLabel.text = viewBeerList[indexPath.row].data()["manufacturer"] as? String
        cell.degreeLabel.text = String(format: "degree: %.1f", viewBeerList[indexPath.row].data()["degree"] as! Double)
        let url = viewBeerList[indexPath.row].data()["avatar"] as? String
        
        if beerImages[url!] == nil {
            Utils().downloadImage(from: URL(string: url!)!, image: cell.beerImageView) {
                (completion) in
                    if completion == nil {}
                    else {
                        self.beerImages[url!] = completion
                    }
            }
        }
        else {
            cell.beerImageView.image = beerImages[url!]
        }
        return cell
    }
    
    @objc func settingsChanged(){
        let cells = self.beerTableView.visibleCells as! Array<CustomTableViewCell>

        for cell in cells {
            let font=UserDefaults.standard.string(forKey: "fontStyle")
            let size=UserDefaults.standard.integer(forKey: "fontSize")
            Utils().styleLabel(cell.titleLabel, fontName: font!, fontSize: size)
        }
    }
}

class CustomTableViewCell : UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var sortLabel: UILabel!
    @IBOutlet weak var manufacturerLabel: UILabel!
    @IBOutlet weak var degreeLabel: UILabel!
    @IBOutlet weak var beerImageView: UIImageView!
}
