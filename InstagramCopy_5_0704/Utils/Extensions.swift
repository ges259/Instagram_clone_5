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




extension Database {
    
    static func fetchUser(with uid: String, completion: @escaping(User) -> ()) {
        // Database.database().reference().child("users")
        USER_REF.child(uid).observeSingleEvent(of: .value) { snapshot in
            
            guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else { return }

            let user = User(uid: uid, dictionary: dictionary)
            
            completion(user)
            
        }
    }
    
    static func fetchPost(with postId: String, completion: @escaping(Post)-> ()) {
        
        POSTS_REF.child(postId).observeSingleEvent(of: .value) { snapshot in
            
            guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else { return }
            guard let ownerUid = dictionary["ownerUid"] as? String else { return }
            
            Database.fetchUser(with: ownerUid) { user in
                let post = Post(postId: postId, user: user, dictionary: dictionary)
                
                completion(post)
            }
        }
    }
}
