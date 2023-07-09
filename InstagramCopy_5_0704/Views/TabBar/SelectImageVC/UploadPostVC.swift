//
//  UploadPostVC.swift
//  InstagramCopy_5_0704
//
//  Created by 계은성 on 2023/07/05.
//

import UIKit
import Firebase
import FirebaseStorage

final class UploadPostVC: UIViewController {
    
    
    // MARK: - Properties
    
    
    
    var selectedImage: UIImage?
    
    
    
    // MARK: - ImageView
    private var photoImageView: UIImageView = {
        let img = UIImageView()
        
        img.image = UIImage(named: "profile_unselected")
        img.contentMode = .scaleAspectFill
        img.backgroundColor = .lightGray
        img.clipsToBounds = true
        
        return img
    }()
    
    let captionTextView: UITextView = {
        let tv = UITextView()
        
        tv.backgroundColor = UIColor.groupTableViewBackground
        tv.font = UIFont.systemFont(ofSize: 12)
        
        tv.autocorrectionType = .no
        tv.autocapitalizationType = .none
        
        
        
        return tv
    }()
    
    let shareButton: UIButton = {
        let btn = UIButton(type: .system)
        
        btn.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
        btn.setTitle("Share", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.clipsToBounds = true
        btn.layer.cornerRadius = 5
        btn.isEnabled = false
        
        btn.addTarget(self, action: #selector(handleSharePost), for: .touchUpInside)
        
        return btn
    }()
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        // textView Delegate
        self.captionTextView.delegate = self
        
        // configure view components
        configureViewComponents()

        
        // load image
        loadImage()
        
        self.view.backgroundColor = UIColor.white

        
    }
    
    func configureViewComponents() {
        
        self.view.addSubview(self.photoImageView)
        self.view.addSubview(self.captionTextView)
        self.view.addSubview(self.shareButton)
        
        self.photoImageView.anchor(top: self.view.topAnchor, bottom: nil,
                                   leading: self.view.leadingAnchor, trailing: nil,
                                   paddingTop: 92, paddingBottom: 0,
                                   paddingLeading: 12, paddingTrailing: 0,
                                   width: 100, height: 100)
        
        self.captionTextView.anchor(top: self.view.topAnchor, bottom: nil,
                                    leading: self.photoImageView.trailingAnchor, trailing: self.view.trailingAnchor,
                                    paddingTop: 92, paddingBottom: 0,
                                    paddingLeading: 12, paddingTrailing: 12,
                                    width: 0, height: 100)
        
        self.shareButton.anchor(top: self.photoImageView.bottomAnchor, bottom: nil,
                                leading: self.view.leadingAnchor, trailing: self.view.trailingAnchor,
                                paddingTop: 12, paddingBottom: 0,
                                paddingLeading: 24, paddingTrailing: 24,
                                width: 0, height: 40)
    }
    
    
    
    func loadImage() {
        guard let selectedImage = selectedImage else { return }
        
        self.photoImageView.image = selectedImage
        
    }
    
    
    
    // MARK: - handler
    func updateUserFeeds(with postId: String) {
        // current user id
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        // database values
        let values = [postId: 1]
        
        // update follow feed
        USER_FOLLOWER_REF.child(currentUid).observe(.childAdded) { snapshot in
            
            let followUid = snapshot.key
            // update user-feed
            // 자신이 follow한 모든 사람의 user-feed에 자신의 포스트를 올림
            USER_FEED_REF.child(followUid).updateChildValues(values)
            print("************* follow Id is: \(followUid) *************")
        }
        // update current user feed
        // 자신의 user-post에 포스트를 올림
        USER_FEED_REF.child(currentUid).updateChildValues(values)
        print("current id is \(currentUid)")
    }
    
    
    
    @objc private func handleSharePost() {
        
        // paramaters
        guard
            let caption = captionTextView.text,
            let postImg = photoImageView.image,
            let currentId = Auth.auth().currentUser?.uid
        else { return }
        
        // image upload data
        guard let uploadData = postImg.jpegData(compressionQuality: 0.3) else { return }
        
        // creation date
        let creationDate = Int(NSDate().timeIntervalSince1970)
        
        // update storage
        let fileName = NSUUID().uuidString
        
        
        let storageRef = Storage.storage().reference().child("post_images").child(fileName)
        
        storageRef.putData(uploadData) { metaData, error in
            
            // handle error
            if let error = error {
                print("Failed to upload image to stoage with error", error.localizedDescription)
                return
            }
            
            
            storageRef.downloadURL { downloadURL, error in
                
                // image url
                guard let postImageUrl = downloadURL?.absoluteString else {
                    print("DEBUG: Post image url is nil")
                    return
                }
                
                // post data
                let values = ["caption": caption,
                             "creationDate": creationDate,
                             "likes": 0,
                             "imageUrl":postImageUrl,
                             "ownerUid": currentId] as [String: Any]
                
                // post id
                let postId = POSTS_REF.childByAutoId()
                guard let postKey = postId.key else { return }
                
                // upload information to database
                postId.updateChildValues(values) { err, ref in
                    
                    guard let postKey = postId.key else { return }
                    
                    // update user-post structure
                    // user-post가 하는 일: 어떤 사용자가 어떤 게시물을 올렸는지 확인이 가능하다.
                    USER_POSTS_REF.child(currentId).updateChildValues([postKey: 1])
                    
                    // update user-feed structure
                    self.updateUserFeeds(with: postKey)
                    
                    // return to home feed
                    self.dismiss(animated: true) {
                        self.tabBarController?.selectedIndex = 0
                    }
                }
            }
        }
    }
    
    
    
    
    
    
}


// MARK: - UITextView - Delegate
extension UploadPostVC: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        
        guard !textView.text.isEmpty else {
            self.shareButton.isEnabled = false
            self.shareButton.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
            return
        }
        self.shareButton.isEnabled = true
        self.shareButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
    }
}
