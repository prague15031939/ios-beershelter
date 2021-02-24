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
    }
}

extension TableViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return beerList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath) as! CustomTableViewCell
        cell.titleLabel.text = beerList[indexPath.row].data()["title"] as? String
        cell.sortLabel.text = beerList[indexPath.row].data()["sort"] as? String
        let url = beerList[indexPath.row].data()["avatar"] as? String
        downloadImage(from: URL(string: url!)!, image: cell.beerImageView)
        return cell
    }
    
}

class CustomTableViewCell : UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var sortLabel: UILabel!
    @IBOutlet weak var beerImageView: UIImageView!
}
