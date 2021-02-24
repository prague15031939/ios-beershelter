//
//  dao.swift
//  BeerShelter
//
//  Created by NASTUSYA on 2/24/21.
//

import Foundation
import Firebase
import AVFoundation
import AVKit


func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
    URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
}

func downloadImage(from url: URL, image: UIImageView) {
    getData(from: url) { data, response, error in
        guard let data = data, error == nil else { return }
        print(response?.suggestedFilename ?? url.lastPathComponent)
        DispatchQueue.main.async() {
            image.image = UIImage(data: data)
        }
    }
}

func createThumbnailOfVideoFromFileURL(videoURL: URL, completion: ((_ image: UIImage?) -> Void)) {
    let asset = AVAsset(url: videoURL)
    let assetImgGenerate = AVAssetImageGenerator(asset: asset)
    assetImgGenerate.appliesPreferredTrackTransform = true
    let time = CMTimeMake(value: 7, timescale: 1)
    do {
        let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
        let thumbnail = UIImage(cgImage: img)
        completion(thumbnail)
    } catch {
        print(error.localizedDescription)
        completion(nil)
    }
}
