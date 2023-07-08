//
//  Extensions.swift
//  InstagramCopy_5_0704
//
//  Created by 계은성 on 2023/07/04.
//

import UIKit
import FirebaseDatabase


extension UIButton {
    
    func configure(didFollow: Bool) {
        
        if didFollow {
            // handle follow user
            self.setTitle("Following", for: .normal)
            self.setTitleColor(.black, for: .normal)
            self.layer.borderWidth = 0.5
            self.backgroundColor = .white
            
        } else {
            
            // handle unfollow user
            self.setTitle("Follow", for: .normal)
            self.setTitleColor(.white, for: .normal)
            self.layer.borderWidth = 0
            self.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
        }
    }
}

extension UIView {
    func anchor(top: NSLayoutYAxisAnchor?, bottom: NSLayoutYAxisAnchor?,
                leading: NSLayoutXAxisAnchor?, trailing: NSLayoutXAxisAnchor?,
                paddingTop: CGFloat, paddingBottom: CGFloat,
                paddingLeading: CGFloat, paddingTrailing: CGFloat,
                width: CGFloat, height: CGFloat) {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        if let bottom = bottom {
            self.bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        if let leading = leading {
            self.leadingAnchor.constraint(equalTo: leading, constant: paddingLeading).isActive = true
        }
        if let trailing = trailing {
            self.trailingAnchor.constraint(equalTo: trailing, constant: -paddingTrailing).isActive = true
        }
        
        if width != 0 {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        if height != 0 {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
}


var imageCache = [String: UIImage]()

extension UIImageView {
    
    func loadImageView(with urlString: String) {
        
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
            
            // image data
            guard let imageData = data else { return }
            
            // set image using image data
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


extension Database {
    
    static func fetchUser(with uid: String, completion: @escaping(User) -> ()) {
        
        USER_REF.child(uid).observeSingleEvent(of: .value) { snapshot in
            guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else { return }
            
            let user = User(uid: uid, dictionary: dictionary)
            
            completion(user)
            
        }
        
        
        
    }
}
