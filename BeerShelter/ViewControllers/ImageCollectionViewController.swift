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
    var videos : Array<String>?
    var itemCategories = ["photo", "video"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if photos == nil || videos == nil {
            print("error on segue")
        }
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
    }
    
    func openVideoPlayer(_ ref: String) {
        print(ref)
        
        let url = URL(string: ref)
        let player = AVPlayer(url: url!)
        
        let vc = AVPlayerViewController()
        vc.player = player
        self.present(vc, animated: true) { vc.player?.play() }
    }

}

extension ImageCollectionViewController : UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return photos!.count
        }
        else if section == 1 {
            return videos!.count
        }
        return 0
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return itemCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! CustomCollectionViewCell
        
        if indexPath.section == 0 {
            let url = photos![indexPath.row]
            Utils().downloadImage(from: URL(string: url)!, image: cell.beerImageView, completion: { _ in })
        }
        else if indexPath.section == 1 {
            let url = URL(string: videos![indexPath.row])!
            Utils().createThumbnailOfVideoFromFileURL(videoURL: url) {
            (completion) in
                if completion == nil {}
                else {
                    cell.beerImageView.image = completion
                }
            }
        }

        return cell
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            openVideoPlayer(videos![indexPath.row])
        }
        collectionView.deselectItem(at: indexPath, animated: true)
     }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "sectionHeaderView", for: indexPath) as! SectionHeaderView
        
        let category = itemCategories[indexPath.section]
        header.categoryTitle = category
        return header
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

class SectionHeaderView : UICollectionReusableView {
    @IBOutlet weak var categoryTitleLabel: UILabel!
    @IBOutlet weak var categoryImage: UIImageView!
    
    var categoryTitle : String! {
        didSet {
            categoryTitleLabel.text = categoryTitle
            categoryImage.image = UIImage(systemName: categoryTitle)
        }
    }
}
