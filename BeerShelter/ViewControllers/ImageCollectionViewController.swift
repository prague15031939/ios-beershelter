//
//  ImageCollectionViewController.swift
//  BeerShelter
//
//  Created by NASTUSYA on 2/24/21.
//

import UIKit
import AVFoundation
import AVKit

class ImageCollectionViewController: UIViewController {

    @IBOutlet weak var imageCollectionView: UICollectionView!
    var photos : Array<String>?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if photos == nil {
            print("error on segue")
        }

        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
    }
    
    func openVideoPlayer(_ ref: String) {
        let url = URL(string: ref)
        let player = AVPlayer(url: url!)
        
        let vc = AVPlayerViewController()
        vc.player = player
        self.present(vc, animated: true) { vc.player?.play() }
    }

}

extension ImageCollectionViewController : UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! CustomCollectionViewCell
        
        let border = photos!.count - 1
        if indexPath.row < border {
            let url = photos![indexPath.row]
            downloadImage(from: URL(string: url)!, image: cell.beerImageView)
        }
        else{
            let index = 3
            let url = URL(string: photos![index])
            createThumbnailOfVideoFromFileURL(videoURL: url!) {
            (completion) in
                if completion==nil{}
                else{
                    cell.beerImageView.image = completion
                }
                           
            }
        }
        return cell
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 3 {
            openVideoPlayer(photos![3])
        }
        collectionView.deselectItem(at: indexPath, animated: true)
     }
    
}

extension ImageCollectionViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let noOfCellsInRow = 3

        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
            flowLayout.estimatedItemSize = .zero

        let totalSpace = flowLayout.sectionInset.left
            + flowLayout.sectionInset.right
            + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))

        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(noOfCellsInRow))

        return CGSize(width: size, height: size)
    }
}

class CustomCollectionViewCell : UICollectionViewCell {
    @IBOutlet weak var beerImageView: UIImageView!
}

