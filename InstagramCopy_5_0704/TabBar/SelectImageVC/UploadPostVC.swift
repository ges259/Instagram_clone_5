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
    // SelectImageVC에서 이미지를 받아옴
        // didSet을 통해 이미지 넣기
    var selectedImage: UIImage? {
        didSet {
            guard let selectedImage = selectedImage else { return }
            
            self.photoImageView.image = selectedImage
        }
    }
    // post를 수정하기 위해 UploadPostVC에 들어온다면
        // 해당 변수에 post가 담김
        // 이 변수를 수정하여 그대로 DB에 업데이트
    var postToEdit: Post?
    // 수정인지 업로드인지를 판단하는 변수
    var uploadAction: UploadAction!
    
    
    // MARK: - Layout
    private var photoImageView: CustomImageView = {
        return CustomImageView().configureCustomImageView()
    }()
    
    private let captionTextView: UITextView = {
        let tv = UITextView()
        
        tv.backgroundColor = UIColor.groupTableViewBackground
        tv.font = UIFont.systemFont(ofSize: 12)
        
        tv.autocorrectionType = .no
        tv.autocapitalizationType = .none
        
        return tv
    }()
    
    private lazy var actionButton: UIButton = {
        let btn = UIButton().button(title: "Share",
                                    titleColor: .white,
                                    backgroundColor: UIColor.textFieldGray,
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
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // post 수정
        if self.uploadAction == .SaveChanges {
            self.actionButton.setTitle("SaveChanges", for: .normal)
            
            self.navigationItem.title = "Edit Post"
            self.navigationController?.navigationBar.tintColor = .black
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                                    style: .plain,
                                                                    target: self,
                                                                    action: #selector(self.handleCancel))
            
            guard let post = self.postToEdit else { return }
            self.photoImageView.loadImageView(with: post.imageUrl)
            self.captionTextView.text = post.caption
        
        // post 업로드
        } else {
            self.actionButton.setTitle("Share", for: .normal)
            self.navigationItem.title = "Upload Post"
        }
    }
    
    
    
    // MARK: - Helper Functions
    private func configureViewComponents() {
        // background Color
        self.view.backgroundColor = UIColor.white
        
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
    
    // selector -> buttonSelector
    private func buttonSelector(uploadAction: UploadAction) {
        switch uploadAction {
        case .UploadPost:
            self.handleUploadPost()
            
            
        case .SaveChanges:
            self.handleSavePostChanges()
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
    
    
    
    // MARK: - API
    // post 수정
    private func handleSavePostChanges() {
        guard let post = self.postToEdit else { return }
        let updateCaption = captionTextView.text
        
        self.uploadHashtagToServer(withPostId: post.postId)
        
        POSTS_REF.child(post.postId).child("caption").setValue(updateCaption) { err, ref in
            self.dismiss(animated: true, completion: nil)
        }
    }
    // post 업로드
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
        // 파일 이름 만들기 (uuidString 사용 32개의 16진수)
        let fileName = NSUUID().uuidString
        
        // 이미지를 저장할 storage 경로 만들기
        let storageRef = Storage.storage().reference().child("post_images").child(fileName)
        
        // storage에 데이터 저장
        storageRef.putData(uploadData) { metaData, error in
            // handle error
            if let error = error {
                print("Failed to upload image to stoage with error", error.localizedDescription)
                return
            }
            // storage에 이미지 저장 완료. 이후 과정
            // realtime_DB에 이미지url을 저장하기 위해
                // storage에서 url을 다운로드
            storageRef.downloadURL { downloadURL, error in
                // image url
                // 이미지가 있는지 확인
                guard let postImageUrl = downloadURL?.absoluteString else {
                    print("DEBUG: Post image url is nil")
                    return
                }
                // post data
                // realtime_DB에 저장할 때 배열로 만들어서 저장
                let values = ["caption": caption,
                              "creationDate": creationDate,
                              "likes": 0,
                              "imageUrl":postImageUrl,
                              "ownerUid": currentId] as [String: Any]
                // post id
                let postId = POSTS_REF.childByAutoId()
                guard let postKey = postId.key else { return }
                
                // upload information to database
                // realtime_DB에 데이터를 저장(업데이트)
                postId.updateChildValues(values) { err, ref in
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
                    // 업로드를 하고나면 feed로 가기 (index == 0 <<<<<---- feed)
                    self.dismiss(animated: true) {
                        self.tabBarController?.selectedIndex = 0
                    }
                }
            }
        }
    }
    
    // 포스트를 업로드 하면 -> 자신이 팔로우한 사람들의 DB에 추가된다.
        // feed에서 자신이 팔로우한 사람의 post를 보기 위함
    private func updateUserFeeds(with postId: String) {
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
    
    // 해쉬태그
        // 수정 및 업로드 모두
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
}



// MARK: - UITextView - Delegate
extension UploadPostVC: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        
        guard !textView.text.isEmpty else {
            self.actionButton.isEnabled = false
            self.actionButton.backgroundColor = UIColor.textFieldGray
            return
        }
        self.actionButton.isEnabled = true
        self.actionButton.backgroundColor = UIColor.buttonBlue
    }
}
