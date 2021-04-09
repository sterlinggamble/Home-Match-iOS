//
//  Matcher.swift
//  Home Match
//
//  Created by Sterling Gamble on 4/7/21.
//

import Foundation
import Vision

class Matcher {
    func processImages(sourceImage: URL?, listings: [Home]) -> [Home] {
        guard let sourceImage = sourceImage else {
            return listings
        }
        
        guard let originalFPO = featureprintObservationForImage(atURL: sourceImage) else {
            return listings
        }
        
        // calculate the distance between the orginal image and the listings
        for listing in listings {
            let listingImageURL = URL(string: listing.imageURL!)
            if let listingFPO = featureprintObservationForImage(atURL: listingImageURL!) {
                do {
                    var distance = Float(0)
                    try listingFPO.computeDistance(&distance, to: originalFPO)
                    listing.score = distance
                } catch {
                    print("Featureprint error: \(error.localizedDescription)")
                }
            }
        }
        
        // the closer the distance, the higher the rank
        let sortedListing = listings.sorted(by: {$0.score < $1.score})
        
        return sortedListing
    }
    
    func test() {
        let originalImageURL = URL(string: "https://www.houseplans.net/news/wp-content/uploads/2020/07/Modern-963-00433.jpg?w=640")
        
        guard let originalFPO = featureprintObservationForImage(atURL: originalImageURL!) else {
            return
        }
        
        let contestantImageURL = URL(string: "https://www.oregonlive.com/resizer/88IoU5GCIMxlrRs7agJuODv3hs4=/450x0/smart/advancelocal-adapter-image-uploads.s3.amazonaws.com/expo.advance.net/img/951107a78f/width2048/c2a_3dacs1904250029.jpeg")
        
        
        if let contestantFPO = featureprintObservationForImage(atURL: contestantImageURL!) {
            do {
                var distance = Float(0)
                try contestantFPO.computeDistance(&distance, to: originalFPO)
                print(distance)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    // From Apple Vision Image Similarity Game Sample Project
    func featureprintObservationForImage(atURL url: URL) -> VNFeaturePrintObservation? {
        let requestHandler = VNImageRequestHandler(url: url, options: [:])
        let request = VNGenerateImageFeaturePrintRequest()
        do {
            try requestHandler.perform([request])
            return request.results?.first as? VNFeaturePrintObservation
        } catch {
            print("Vision error: \(error)")
            return nil
        }
    }
}
