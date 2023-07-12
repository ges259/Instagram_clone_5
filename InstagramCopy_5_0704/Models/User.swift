//
//  User.swift
//  InstagramCopy_5_0704
//
//  Created by 계은성 on 2023/07/05.
//
import FirebaseAuth
import Firebase


class User {
    // attributesw
    var userName: String!
    var name: String!
    var profileImageUrl: String!
    var uid: String!
    var isFollowed: Bool = false
    
    
    init(uid: String, dictionary: Dictionary<String, AnyObject>) {
        
        self.uid = uid
        
        
        if let userName = dictionary["userName"] as? String {
            self.userName = userName
        }
        
        if let name = dictionary["name"] as? String {
            self.name = name
        }
        
        if let profileImageUrl = dictionary["profileImageUrl"] as? String {
            self.profileImageUrl = profileImageUrl
        }
    }
    
    
    // follow
    func follow() {
        // DNS에 로그인한 사람을 확인해야 하기 때문에 현재 사용자 id를 얻는다.
        guard let currentId = Auth.auth().currentUser?.uid else { return }
        // uid 옵셔널 바인딩
        guard let uid = uid else { return }
        
        // set is followed to true
        self.isFollowed = true
        
        // 데이터베이스 항목
        // add followed user to current user-following structure
        // 현재 사용자 팔로우 구조에 팔로우된 사용자 추가
        USER_FOLLOWING_REF.child(currentId).updateChildValues([uid: 1])
        
        // add current user to followed user-follower structure
        // 현재 사용자를 팔로우하는 사용자 팔로우 구조에 추가
        USER_FOLLOWER_REF.child(uid).updateChildValues([currentId: 1])
        
        // upload follow notification to server
        uploadFollowNotificationToServer()
        
        // add followed users posts to current user-feed
        USER_POSTS_REF.child(uid).observe(.childAdded) { snapshot in
            let postId = snapshot.key
            USER_FEED_REF.child(currentId).updateChildValues([postId: 1])
        }

        
    }
    // unfollow
    func unfollow() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        // UPDATE: - get uid like this to work with update
        guard let uid = uid else { return }
        
        self.isFollowed = false

        USER_FOLLOWING_REF.child(currentUid).child(uid).removeValue()
        
        USER_FOLLOWER_REF.child(uid).child(currentUid).removeValue()
        
        USER_POSTS_REF.child(uid).observe(.childAdded) { (snapshot) in
            let postId = snapshot.key
            USER_FEED_REF.child(currentUid).child(postId).removeValue()
        }
    }
    
    
    func checkIfUserIsFollowed(completion: @escaping(Bool) -> ()) {
        
        guard let currentId = Auth.auth().currentUser?.uid else { return }
        
        USER_FOLLOWING_REF.child(currentId).observeSingleEvent(of: .value) { snapshot in
            
            if snapshot.hasChild(self.uid) {
                self.isFollowed = true
                completion(true)
            } else {
                self.isFollowed = false
                completion(false)
            }
        }
    }
    
    func uploadFollowNotificationToServer() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let creationDate = Int(NSDate().timeIntervalSince1970)
        let values = ["checked": 0,
                      "creationDate": creationDate,
                      "uid": currentUid,
                      "type": FOLLOW_INT_VALUE] as [String: Any]
        
        NOTIFICATIONS_REF.child(self.uid).childByAutoId().updateChildValues(values)
        
        
    }
    
}
