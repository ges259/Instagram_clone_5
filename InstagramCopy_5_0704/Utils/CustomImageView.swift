//
//  CustomImageView.swift
//  InstagramCopy_5_0704
//
//  Created by 계은성 on 2023/07/08.
//

import UIKit
// 이미지를 캐시에 넣기
var imageCache = [String: UIImage]()

final class CustomImageView: UIImageView {
    // 이미지 중복 확인을 위해 필요한 변수
    var lastImgUrlUsedToLoadImage: String?
    
    // URL을 통해 이미지를 불러오는 API함수
    func loadImageView(with urlString: String) {
        // set image to nil
        self.image = nil
        // set lastImgUrlUsedToLoadImage
        self.lastImgUrlUsedToLoadImage = urlString
        
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
            
            // image url 데이터가 있는 지 확인
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

extension CustomImageView {
    func configureCustomImageView() -> CustomImageView {
        let img = CustomImageView()
        
        img.contentMode = .scaleAspectFill
        img.backgroundColor = .lightGray
        // clipsToBounds는 뭐를 위한걸까?
            // width, height 설정을 위해서 ????
        img.clipsToBounds = true
        
        return img
    }
}
