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
    var beerList : Array<QueryDocumentSnapshot>?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collection = mapView.mapWindow.map.mapObjects.addClusterizedPlacemarkCollection(with: self)
        collection?.addTapListener(with: self)
        
        createPoints()

    }
    
    func onClusterAdded(with cluster: YMKCluster) {
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
}

extension MapViewController: YMKMapObjectTapListener {
    func onMapObjectTap(with mapObject: YMKMapObject, point: YMKPoint) -> Bool {
        return true
    }
}
