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
    // 어떤 포스트의 comment Controller인지 판단하기 위한 변수
    var post: Post?
    
    
    
    // MARK: - Layout
    // commentVC 하단 텍스트필드 및 버튼 구성
    private lazy var containerView: CommentAccessoryView = {
        let frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        let cv = CommentAccessoryView(frame: frame)
            cv.delegate = self
            cv.backgroundColor = .white
        return cv
    }()
    
    
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // configure collection view
        self.configureCollectionView()
        
        // fetch comments
        self.fetchComments()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    // accessoryView 넣기
    override var inputAccessoryView: UIView? {
        get {
            return self.containerView
        }
    }
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    
    
    // MARK: - Helper Functions
    private func configureCollectionView() {
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
    
    
    // MARK: - ActiveLabel Functions
    // cocoapod의 'ActiveLabel' 기능, completion을 통해 기능
        // -> 미리 기능들을 넣어둠
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
            self.getMentionUser(withuserName: userName)
        }
    }
    
    
    
    // MARK: - CollectionView
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
        return self.comments.count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CommentCell
            cell.comment = self.comments[indexPath.item]
        // ActiveLabel
        // cocoapod의 'ActiveLabel' 기능, completion을 통해 기능
            // -> 미리 기능들을 넣어둠
        self.handleHastagTapped(forcell: cell)
        self.handleMentionTapped(forCell: cell)
        
        return cell
    }
    
    
    
    // MARK: - API
    // comment를 가져오는 API 함수
    private func fetchComments() {
        guard let postId = self.post?.postId else { return }
        // observe로 셋팅 -> comment가 추가되면 추적
        COMMENT_REF.child(postId).observe(.childAdded) { snapshot in
            guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else { return }
            guard let uid = dictionary["uid"] as? String else { return }
            
            // extension에 있는 fetchUser를 통해서 추가된(업데이트)된 user들의 데이터들을 가져온다.
            Database.fetchUser(with: uid) { (user) in
                let comment = Comment(user: user, dictionary: dictionary)
                self.comments.append(comment)
                self.collectionView.reloadData()
            }
        }
    }
}



// MARK: - Delegate
extension CommentVC: CommentInputAccesoryViewDelegate {
    
    func didSubmit(forComment comment: String) {
        guard let postId = self.post?.postId else { return }
        guard let uid = Auth.auth().currentUser?.uid else  { return }
        let creationDate = Int(NSDate().timeIntervalSince1970)
        
        let values = ["commentText": comment,
                      "creationDate": creationDate,
                      "uid": uid] as [String : Any]
        
        // comment를 DB에 저장
        COMMENT_REF.child(postId).childByAutoId().updateChildValues(values) { Error, ref in
            self.uploadCommentNotificationToServer()
            
            // 맨션이 있다면 따로 저장
            if comment.contains("@") {
                self.uploadMentionNotification(forPostId: postId, withText: comment, isForComment: true)
            }
            self.containerView.clearCommentTextView()
        }
    }
}
