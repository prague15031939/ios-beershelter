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
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var beerList = Array<QueryDocumentSnapshot>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.alpha=1
        activityIndicator.startAnimating()
        
        loadBeerItems() { (completion) in
            if completion == nil {
                print("Error loading characters")
            }
            else{
                self.beerList = completion!
                self.beerTableView.reloadData()
                
                self.activityIndicator.stopAnimating()
                self.activityIndicator.alpha = 0
            }
                
        }
        
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
                destVC.info = beerList[indexPath.row]
            }
        }
        if segue.identifier == "mapSegue" {
            let destVC = segue.destination as! MapViewController
            destVC.beerList = beerList
        }
    }
}

extension TableViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return beerList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath) as! CustomTableViewCell
        //if indexPath.row % 2 == 1 {
        //    cell.backgroundColor = UIColor.systemGray6
        //}
        cell.titleLabel.text = beerList[indexPath.row].data()["title"] as? String
        cell.sortLabel.text = "sort: " + (beerList[indexPath.row].data()["sort"] as! String)
        cell.manufacturerLabel.text = beerList[indexPath.row].data()["manufacturer"] as? String
        cell.degreeLabel.text = String(format: "degree: %.1f", beerList[indexPath.row].data()["degree"] as! Double)
        let url = beerList[indexPath.row].data()["avatar"] as? String
        Utils().downloadImage(from: URL(string: url!)!, image: cell.beerImageView)
        return cell
    }
    
}

class CustomTableViewCell : UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var sortLabel: UILabel!
    @IBOutlet weak var manufacturerLabel: UILabel!
    @IBOutlet weak var degreeLabel: UILabel!
    @IBOutlet weak var beerImageView: UIImageView!
}
