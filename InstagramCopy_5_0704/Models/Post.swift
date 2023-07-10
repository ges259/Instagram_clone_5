//
//  Post.swift
//  InstagramCopy_5_0704
//
//  Created by 계은성 on 2023/07/08.
//
import Foundation
import Firebase

final class Post {
    var caption: String!
    var likes: Int!
    var imageUrl: String!
    var ownerUid: String!
    var creationDate: Date!
    var postId: String!
    var user: User?
    var didLike: Bool = false
    
    init(postId: String!, user: User, dictionary: Dictionary<String, AnyObject>) {
        
        self.postId = postId
        self.user = user
        
        if let caption = dictionary["caption"] as? String {
            self.caption = caption
        }
        
        if let likes = dictionary["likes"] as? Int {
            self.likes = likes
        }
        
        if let imageUrl = dictionary["imageUrl"] as? String {
            self.imageUrl = imageUrl
        }
        
        if let ownerUid = dictionary["ownerUid"] as? String {
            self.ownerUid = ownerUid
        }
        
        if let creationDate = dictionary["creationDate"] as? Double {
            self.creationDate = Date(timeIntervalSince1970: creationDate)
        }
    }
    
    func adjustLikes(addLike: Bool, completion: @escaping(Int) -> ()) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard let postId = self.postId else { return }
        
        if addLike {
            // updates user-like structure
            USER_LIKES_REF.child(currentUid).updateChildValues([postId: 1]) { error, ref in
                // update post-like structrue
                POST_LIKES_REF.child(postId).updateChildValues([currentUid: 1]) { error, ref in
                    self.likes = self.likes + 1
                    self.didLike = true
                    completion(self.likes)
                    POSTS_REF.child(postId).child("likes").setValue(self.likes)
                }
                
            }
            
            
        } else {
            // remove like from user-like s tructure
            USER_LIKES_REF.child(currentUid).child(postId).removeValue { error, ref in
                // remove post-like structure
                POST_LIKES_REF.child(self.postId).child(currentUid).removeValue { error, ref in
                    guard self.likes > 0 else { return }
                    self.likes = self.likes - 1
                    self.didLike = false
                    completion(self.likes)
                    POSTS_REF.child(self.postId).child("likes").setValue(self.likes)
                }
            }
        }
    }
}
