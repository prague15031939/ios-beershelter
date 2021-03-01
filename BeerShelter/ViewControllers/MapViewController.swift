//
//  MapViewController.swift
//  BeerShelter
//
//  Created by NASTUSYA on 2/25/21.
//

import UIKit
import Firebase
import YandexMapKit

class MapViewController: UIViewController, YMKClusterListener {
    
    @IBOutlet weak var mapView: YMKMapView!
    var collection: YMKClusterizedPlacemarkCollection?
    var beerList: Array<QueryDocumentSnapshot>?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        collection = mapView.mapWindow.map.mapObjects.addClusterizedPlacemarkCollection(with: self)
        collection?.addTapListener(with: self)
        
        if (beerList == nil) {
            loadBeerItems() { (completion) in
                if completion == nil {
                    print("Error loading characters")
                }
                else {
                    self.beerList = completion!
                    self.createPoints()
                }
            }
        }
        else {
            createPoints()
        }
    }
    
    func onClusterAdded(with cluster: YMKCluster) {
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
    
    func createPoints(){
        
        for item in beerList! {
            let point = YMKPoint(latitude: item.data()["latitude"] as! Double, longitude: item.data()["longitude"] as! Double)
            let placemark = collection?.addPlacemark(with: point,
            image: UIImage(systemName:  "mappin.circle")!, style: YMKIconStyle.init())
            placemark?.userData = item
        }

        collection?.clusterPlacemarks(withClusterRadius: 5, minZoom: 15)
    }
    
    func transitionToDetailed(_ beerData: QueryDocumentSnapshot) {
            
        let tableViewController = (storyboard?.instantiateViewController(identifier: "tableVC") as? TableViewController)!
        let mapViewController = (storyboard?.instantiateViewController(identifier: "mapVC") as? MapViewController)!
        let detailedViewController = (storyboard?.instantiateViewController(identifier: "detailedVC") as? BeerInfoViewController)!
        let navViewController = storyboard?.instantiateViewController(identifier: "navVC") as? UINavigationController
        detailedViewController.info = beerData
        navViewController?.pushViewController(tableViewController, animated: true)
        navViewController?.pushViewController(mapViewController, animated: true)
        navViewController?.pushViewController(detailedViewController, animated: true)
        view.window?.rootViewController = navViewController
        view.window?.makeKeyAndVisible()
            
    }
}

extension MapViewController: YMKMapObjectTapListener {
    func onMapObjectTap(with mapObject: YMKMapObject, point: YMKPoint) -> Bool {
        guard let userPoint = mapObject as? YMKPlacemarkMapObject else {
            return true
        }
        print(userPoint.userData!)
        transitionToDetailed(userPoint.userData! as! QueryDocumentSnapshot)
        return true
    }
}
