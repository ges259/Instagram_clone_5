//
//  Extensions.swift
//  InstagramCopy_5_0704
//
//  Created by 계은성 on 2023/07/04.
//

import UIKit
import Firebase


extension Date {
    func timeAgoToDisplay() -> String {
        let secondsAgo = Int(Date().timeIntervalSince(self))
        
        let minute: Int = 60
        let hour: Int = 60 * minute
        let day: Int = 24 * hour
        let week: Int = 7 * day
        let month: Int = 4 * week
        
        let quotient: Int // 몫
        let unit: String
        
        if secondsAgo < minute {
            quotient = secondsAgo
            unit = "SECOND"
        } else if secondsAgo < hour {
            quotient = secondsAgo / minute
            unit = "MIN"
        } else if secondsAgo < day {
            quotient = secondsAgo / hour
            unit = "HOUR"
        } else if secondsAgo < week {
            quotient = secondsAgo / day
            unit = "DAY"
        } else if secondsAgo < month {
            quotient = secondsAgo / week
            unit = "WEEK"
        } else {
            quotient = secondsAgo / month
            unit = "MONTH"
        }
        
        return "\(quotient) \(unit)\(quotient == 1 ? "" : "S" ) AGO"
    }
}




extension UIColor {
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
}


extension UIViewController {
    func getMentionUser(withuserName userName: String) {
        
        USER_REF.observe(.childAdded) { snapshot in
            let uid = snapshot.key
            
            USER_REF.child(uid).observeSingleEvent(of: .value) { snapshot in
                guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else { return }
                
                if userName == dictionary["userName"] as? String {
                    Database.fetchUser(with: uid) { user in
                        let userProfileVC = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
                        userProfileVC.user = user
                        self.navigationController?.pushViewController(userProfileVC, animated: true)
                        return
                    }
                }
            }
        }
    }
    
    func uploadMentionNotification(forPostId postId: String, withText text: String, isForComment: Bool) {
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let creationDate = Int(NSDate().timeIntervalSince1970)
        
        let words: [String] = text.components(separatedBy: .whitespacesAndNewlines)
        
        var mentionIntegerValue: Int!
        
        if isForComment {
            mentionIntegerValue = COMMENT_MENTION_INT_VALUE
        } else {
            mentionIntegerValue = POST_MENTION_INT_VALUE
        }
        
        
        
        for var word in words {
            if word.hasPrefix("@") {
                word = word.trimmingCharacters(in: .symbols)
                word = word.trimmingCharacters(in: .punctuationCharacters)
                
                USER_REF.observe(.childAdded) { snapshot in
                    let uid = snapshot.key
                    
                    USER_REF.child(uid).observeSingleEvent(of: .value) { snapshot in
                        guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else { return }
                        
                        if word == dictionary["userName"] as? String {
                            let notificationValues = ["postId": postId,
                                                      "uid": uid,
                                                      "type": mentionIntegerValue as Int,
                                                      "creationDate": creationDate] as [String: Any]
                            
                            if currentUid != uid {
                                NOTIFICATIONS_REF.child(uid).childByAutoId().updateChildValues(notificationValues)
                            }
                        }
                    }
                }
            }
        }
    }
}


extension UIButton {
    
    func configure(didFollow: Bool) {
        
        if didFollow {
            // handle follow user
            self.setTitle("Following", for: .normal)
            self.setTitleColor(.black, for: .normal)
            self.layer.borderWidth = 0.5
            self.layer.borderColor = UIColor.lightGray.cgColor
            self.backgroundColor = .white
            
        } else {
            
            // handle unfollow user
            self.setTitle("Follow", for: .normal)
            self.setTitleColor(.white, for: .normal)
            self.layer.borderWidth = 0
            self.layer.borderColor = .none
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
