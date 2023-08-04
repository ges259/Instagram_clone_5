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
    enum UploadAction: Int {
        case UploadPost
        case SaveChanges
        
        init(index: Int) {
            switch index {
            case 0: self = .UploadPost
            case 1: self = .SaveChanges
            default: self = .UploadPost
            }
        }
    }
    
    var selectedImage: UIImage?
    var postToEdit: Post?
    var uploadAction: UploadAction!
    
    
    // MARK: - Layout
    private var photoImageView: CustomImageView = {
        return CustomImageView().configureCustomImageView()
    }()
    
    let captionTextView: UITextView = {
        let tv = UITextView()
        
        tv.backgroundColor = UIColor.groupTableViewBackground
        tv.font = UIFont.systemFont(ofSize: 12)
        
        tv.autocorrectionType = .no
        tv.autocapitalizationType = .none
        
        return tv
    }()
    
    lazy var actionButton: UIButton = {
        let btn = UIButton().button(title: "Share",
                                    titleColor: .white,
                                    backgroundColor: UIColor.rgb(red: 149, green: 204, blue: 244),
                                    cornerRadius: 5,
                                    isEnable: false)
            btn.addTarget(self, action: #selector(self.handleUploadAction), for: .touchUpInside)
        return btn
    }()
    
    
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
            
        // textView Delegate
        self.captionTextView.delegate = self
        
        // configure view components
        self.configureViewComponents()
        
        // load image
        self.loadImage()
        
        self.view.backgroundColor = UIColor.white
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if uploadAction == .SaveChanges {
            self.actionButton.setTitle("SaveChanges", for: .normal)
            self.navigationItem.title = "Edit Post"
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
            self.navigationController?.navigationBar.tintColor = .black
            
            guard let post = self.postToEdit else { return }
            self.photoImageView.loadImageView(with: post.imageUrl)
            self.captionTextView.text = post.caption
        } else {
            self.actionButton.setTitle("ShareButton", for: .normal)
            self.navigationItem.title = "Upload Post"
        }
    }
    
    
    
    // MARK: - Helper Functions
    func configureViewComponents() {
        // photoImageView
        self.view.addSubview(self.photoImageView)
        self.photoImageView.anchor(top: self.view.topAnchor, paddingTop: 92,
                                   leading: self.view.leadingAnchor, paddingLeading: 12,
                                   width: 100, height: 100)
        // captionTextView
        self.view.addSubview(self.captionTextView)
        self.captionTextView.anchor(top: self.view.topAnchor, paddingTop: 92,
                                    leading: self.photoImageView.trailingAnchor, paddingLeading: 12,
                                    trailing: self.view.trailingAnchor, paddingTrailing: 12,
                                    height: 100)
        // actionButton
        self.view.addSubview(self.actionButton)
        self.actionButton.anchor(top: self.photoImageView.bottomAnchor, paddingTop: 12,
                                 leading: self.view.leadingAnchor, paddingLeading: 24,
                                 trailing: self.view.trailingAnchor, paddingTrailing: 24,
                                 height: 40)
    }
    
    func loadImage() {
        guard let selectedImage = selectedImage else { return }
        
        self.photoImageView.image = selectedImage
    }
    
    
    
    // buttonSelector
    private func buttonSelector(uploadAction: UploadAction) {
        switch uploadAction {
        case .UploadPost:
            self.handleUploadPost()
        case .SaveChanges:
            self.handleSavePostChanges()
        }
    }
    private func handleSavePostChanges() {
        guard let post = self.postToEdit else { return }
        let updateCaption = captionTextView.text
        
        self.uploadHashtagToServer(withPostId: post.postId)
        
        POSTS_REF.child(post.postId).child("caption").setValue(updateCaption) { err, ref in
            self.dismiss(animated: true, completion: nil)
        }
    }
    private func handleUploadPost() {
        
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
                    
                    // update hashtag to server
                    self.uploadHashtagToServer(withPostId: postKey)
                    
                    // upload mention notification to server
                    if caption.contains("@") {
                        self.uploadMentionNotification(forPostId: postKey, withText: caption, isForComment: false)
                    }
                    
                    // return to home feed
                    self.dismiss(animated: true) {
                        self.tabBarController?.selectedIndex = 0
                    }
                }
            }
        }
    }
    
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
    
    
    // MARK: - API
    private func uploadHashtagToServer(withPostId postId: String) {
        
        guard let caption = captionTextView.text else { return }
        
        // 단어들을 배열에 넣기
        let words: [String] = caption.components(separatedBy: .whitespacesAndNewlines)
        
        // 배열에 있는 단어들을 하나하나씩 살펴보기(?)
        for var word in words {
            // #이 앞에 있는 경우
            if word.hasPrefix("#") {
                
                word = word.trimmingCharacters(in: .punctuationCharacters)
                word = word.trimmingCharacters(in: .symbols)
                
                let hashtagValues = [postId: 1]
                
                HASHTAG_POST_REF.child(word.lowercased()).updateChildValues(hashtagValues)
            }
        }
    }
    
    
    
    // MARK: - Selectors
    // Helper Functions ->
    @objc private func handleUploadAction() {
        self.buttonSelector(uploadAction: self.uploadAction)
    }
    
    @objc private func handleCancel() {
        self.dismiss(animated: true, completion: nil)
    }
}



// MARK: - UITextView - Delegate
extension UploadPostVC: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        
        guard !textView.text.isEmpty else {
            self.actionButton.isEnabled = false
            self.actionButton.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
            return
        }
        self.actionButton.isEnabled = true
        self.actionButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
    }
}
