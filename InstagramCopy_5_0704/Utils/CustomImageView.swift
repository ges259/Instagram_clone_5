//
//  CustomImageView.swift
//  InstagramCopy_5_0704
//
//  Created by 계은성 on 2023/07/08.
//

import UIKit

var imageCache = [String: UIImage]()


final class CustomImageView: UIImageView {
    
    var lastImgUrlUsedToLoadImage: String?
    
    func loadImageView(with urlString: String) {
        // set image to nil
        self.image = nil
        // set lastImgUrlUsedToLoadImage
        lastImgUrlUsedToLoadImage = urlString
        
        // check if iamge exists in cache
        if let cachedImage = imageCache[urlString] {
            self.image = cachedImage
            return
        }
        
        // if image does not exists in cache
        guard let url = URL(string: urlString) else { return }
        // fetch contents of URL
        URLSession.shared.dataTask(with: url) { data, response, error in
            // handle error
            if let error = error {
                print("Failed to load image with error", error.localizedDescription)
            }
            
            // 이미지가 중복되는지 확인
            if self.lastImgUrlUsedToLoadImage != url.absoluteString {
                return
            }
            
            // image data
            guard let imageData = data else { return }
            
            // set image using image datas
            let phothoImage = UIImage(data: imageData)
            
            // set key and value for iamge cache
            imageCache[url.absoluteString] = phothoImage
            
            // set image
            DispatchQueue.main.async {
                self.image = phothoImage
            }
        }.resume()
    }
}
