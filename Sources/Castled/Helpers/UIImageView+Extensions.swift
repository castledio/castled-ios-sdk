//
//  UIImageView+Extension.swift
//  Castled
//
//  Created by antony on 04/08/2023.
//

import Foundation
import UIKit
import SDWebImage

extension UIImageView {
    func loadImage(from url: String?) {

        let placeholderImage = UIImage(named: "castled_placeholder", in: Bundle.resourceBundle(for: Castled.self), compatibleWith: nil)
        if let imageUrl = URL(string: url ?? ""){
            self.sd_setImage(with: imageUrl, placeholderImage: placeholderImage)
        }
        else{
            self.image = placeholderImage
        }
    }
   /* func loadImage(from url: URL) {
        let cache = URLCache.shared
        let request = URLRequest(url: url)

        // Try to load the image from the cache
        if let data = cache.cachedResponse(for: request)?.data,
           let image = UIImage(data: data) {
            self.image = image
            return
        }

        // If the image isn't in the cache, download it
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error loading image: \(error.localizedDescription)")
                return
            }

            if let data = data, let response = response,
               let image = UIImage(data: data) {
                // Cache the image
                let cachedData = CachedURLResponse(response: response, data: data)
                cache.storeCachedResponse(cachedData, for: request)

                // Display the image
                DispatchQueue.main.async {
                    self.image = image
                }
            }
        }
        task.resume()
    }*/


}
