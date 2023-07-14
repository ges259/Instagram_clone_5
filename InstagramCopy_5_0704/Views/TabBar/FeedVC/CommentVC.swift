//
//  CommentVC.swift
//  InstagramCopy_5_0704
//
//  Created by 계은성 on 2023/07/10.
//

import UIKit
import Firebase

private let reuseIdentifier = "CommentCell"

final class CommentVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    // MARK: - Properties
    var comments = [Comment]()
    
    var post: Post?
    
    
    
    
    
    
    
    // MARK: - Layout
    private lazy var containerView: UIView = {
        let frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        let cv = UIView(frame: frame)
        
        cv.backgroundColor = .white
        cv.addSubview(self.postButton)
        
        postButton.centerYAnchor.constraint(equalTo: cv.centerYAnchor).isActive = true
        postButton.anchor(top: cv.topAnchor, bottom: cv.bottomAnchor,
                          leading: nil, trailing: cv.trailingAnchor,
                          paddingTop: 0, paddingBottom: 0,
                          paddingLeading: 0, paddingTrailing: 8,
                          width: 40, height: 0)
        
        cv.addSubview(self.commentTextField)
        commentTextField.anchor(top: cv.topAnchor, bottom: cv.bottomAnchor,
                                leading: cv.leadingAnchor, trailing: self.postButton.leadingAnchor,
                                paddingTop: 0, paddingBottom: 0,
                                paddingLeading: 8, paddingTrailing: 8,
                                width: 0, height: 0)
        
        let separatorView = UIView()
        separatorView.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        
        cv.addSubview(separatorView)
        separatorView.anchor(top: cv.topAnchor, bottom: nil, leading: cv.leadingAnchor, trailing: cv.trailingAnchor, paddingTop: 0, paddingBottom: 0, paddingLeading: 0, paddingTrailing: 0, width: 0, height: 0.5)
        
        return cv
    }()
    private lazy var commentTextField: UITextField = {
        let tf = UITextField()
        
        tf.placeholder = "Enter comment..."
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.textColor = .black
        
        
        return tf
    }()
    private lazy var postButton: UIButton = {
        let btn = UIButton()

        btn.setTitle("Post", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        btn.addTarget(self, action: #selector(handleUploadComment), for: .touchUpInside)

        return btn
    }()
    
    
    // MARK: - viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // configure collectin View
        self.collectionView.backgroundColor = .white
        self.collectionView.alwaysBounceVertical = true
        self.collectionView.keyboardDismissMode = .interactive
        
        self.collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -50, right: 0)
        self.collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: -50, right: 0)
        
        // navigation title
        self.navigationItem.title = "Comments"
        
        // register cell class
        self.collectionView!.register(CommentCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        // fetch comments
        fetchComments()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    
    override var inputAccessoryView: UIView? {
        get {
            return containerView
        }
    }
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    
    
    // MARK: - Handler
    @objc private func handleUploadComment() {
        
        guard let postId = self.post?.postId else { return }
        guard let commentText = commentTextField.text else { return }
        guard let uid = Auth.auth().currentUser?.uid else  { return }
        
        let creationDate = Int(NSDate().timeIntervalSince1970)
        
        let values = ["commentText": commentText,
                      "creationDate": creationDate,
                      "uid": uid] as [String : Any]
        
        
        COMMENT_REF.child(postId).childByAutoId().updateChildValues(values) { Error, ref in
            self.uploadCommentNotificationToServer()
            
            if commentText.contains("@") {
                self.uploadMentionNotification(forPostId: postId, withText: commentText, isForComment: true)
            }
            self.commentTextField.text = nil
        }
    }

    
    private func uploadCommentNotificationToServer() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard let post = self.post else { return }
        guard let postId = self.post?.postId else { return }
        guard let uid = post.user?.uid else { return }
        let creationDate = Int(NSDate().timeIntervalSince1970)
        
        // notification values
        let values = ["checked": 0,
                      "creationDate": creationDate,
                      "uid": currentUid,
                      "type": COMMENT_INT_VALUE,
                      "postId": postId] as [String: Any]
        
        // upload comment notification to server
        if uid != currentUid {
            NOTIFICATIONS_REF.child(uid).childByAutoId().updateChildValues(values)
        }
    }
    private func handleHastagTapped(forcell cell: CommentCell) {
        cell.commentLabel.handleHashtagTap { hashtag in
            let hashtagVC = HashtagVC(collectionViewLayout: UICollectionViewFlowLayout())
            hashtagVC.hashtag = hashtag
            hashtagVC.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(hashtagVC, animated: true)
        }
    }
    
    private func handleMentionTapped(forCell cell: CommentCell) {
        cell.commentLabel.handleMentionTap { userName in
            print("Mentioned username is \(userName)")
            self.getMentionUser(withuserName: userName)
        }
    }
    
    
    
    
    
    // MARK: - DataSource
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = self.view.frame.width
        
        let frame = CGRect(x: 0, y: 0, width: width, height: 50)
        let dummyCell = CommentCell(frame: frame)
        dummyCell.comment = comments[indexPath.row]
        dummyCell.layoutIfNeeded()
        
        // 대상의 크기르 만듦, 높이의 상한값처럼 작용하는 임의의 큰 숫자
        let targetSize = CGSize(width: width, height: 1000)
        let estimatedSize = dummyCell.systemLayoutSizeFitting(targetSize)
        
        let height = max(40 + 8 + 8, estimatedSize.height)
        
        
        return CGSize(width: width, height: height)
    }
    // collectionView item
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return comments.count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CommentCell
        
        cell.comment = self.comments[indexPath.item]
        handleHastagTapped(forcell: cell)
        handleMentionTapped(forCell: cell)
        
        return cell
    }
    
    
    
    
    
    
    // MARK: - API
    private func fetchComments() {
        
        guard let postId = self.post?.postId else { return }

        COMMENT_REF.child(postId).observe(.childAdded) { snapshot in

            guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else { return }
            guard let uid = dictionary["uid"] as? String else { return }

            Database.fetchUser(with: uid) { (user) in
                let comment = Comment(user: user, dictionary: dictionary)
                self.comments.append(comment)
                self.collectionView.reloadData()
            }
        }
    }
    
    

    
}
