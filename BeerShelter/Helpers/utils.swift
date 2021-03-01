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
import CryptoKit

class Utils {
    
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

    func getHash(data: String) -> String {
        let inputData = Data(data.utf8)
        let computed = SHA256.hash(data: inputData)
        return computed.map { String(format: "%02hhx", $0) }.joined()
    }
    
    func uploadPhoto(_ imageView: UIImageView, completion:  @escaping (URL?) -> Void){
        
        guard let image=imageView.image, let data=image.jpegData(compressionQuality: 0.6) else {
            
            print("Error uploading image")
            completion(nil)
            return
        }
        let imageReferance=Storage.storage().reference().child("beer_images/" + NSUUID().uuidString)
        
        imageReferance.putData(data, metadata: nil){
            (metadata, err) in
            if let error = err{
                print(error)
                return
            }
            imageReferance.downloadURL(completion: {(url,err) in
                if let error = err{
                    print(error)
                    return
                }
                completion(url)
            })
        }
    }
    
    func deleteDocument(_ ref: String) {
        let reference = Storage.storage().reference(forURL: ref)
        reference.delete { error in
          if let error = error {
            print(error)
          } else {
            print("Deleted")
          }
        }
    }

}
