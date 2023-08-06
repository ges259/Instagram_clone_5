//
//  NotificationsVC.swift
//  InstagramCopy_5_0704
//
//  Created by 계은성 on 2023/07/05.
//

import UIKit
import Firebase

private let reuseIdentifier: String = "NotificationCell"


final class NotificationVC: UITableViewController {
    
    // MARK: - Properties
    var notifications = [Notification]()
    
    var timer: Timer?
    
    var currentKey: String?
    
    
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        // configure TableView + Nav_title
        self.configureTableView()
        
        // fetch notifications
        self.fetchNotifications()
    }
    
    // MARK: - TableView
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as! NotificationCell
            cell.delegate = self
            cell.notification = notifications[indexPath.row]
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let notification = notifications[indexPath.row]
        
        let userProfileVC = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
            userProfileVC.modalPresentationStyle = .fullScreen
            userProfileVC.user = notification.user
        self.navigationController?.pushViewController(userProfileVC, animated: true)
    }
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if self.notifications.count > 4 {
            if indexPath.row == self.notifications.count - 1 {
                self.fetchNotifications()
            }
        }
    }
    
    
    
    // MARK: - Helper Functions
    private func handleReloadTable() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1,
                                          target: self,
                                          selector: #selector(self.handleSortNotifications),
                                          userInfo: nil,
                                          repeats: false)
    }
    
    private func configureTableView() {
        // navigation_title
        self.navigationItem.title = "Notifications"
        
        // configure_tableView
        self.tableView.separatorStyle = .none
        self.tableView.register(NotificationCell.self,
                                forCellReuseIdentifier: reuseIdentifier)
    }
    
    
    
    // MARK: - Selectors
    @objc private func handleSortNotifications() {
        self.notifications.sort { notifications1, notifications2 in
            return notifications1.creationDate > notifications2.creationDate
        }
        self.tableView.reloadData()
    }
    
    
    
    // MARK: - API
    func fetchNotifications() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        if currentKey == nil {
            NOTIFICATIONS_REF.child(currentUid).queryLimited(toLast: 5).observeSingleEvent(of: .value) { snapshot in
                
                guard let first = snapshot.children.allObjects.first as? DataSnapshot else { return }
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
                
                allObjects.forEach { snapshot in
                    
                    let notificationId = snapshot.key
                    
                    self.fetchNotifications(withNotificationId: notificationId, dataSnapshot: snapshot)
                }
                self.currentKey = first.key
            }
        }else {
            NOTIFICATIONS_REF.child(currentUid).queryOrderedByKey().queryEnding(atValue: self.currentKey).queryLimited(toLast: 6).observeSingleEvent(of: .value) { snapshot in
                
                guard let first = snapshot.children.allObjects.first as? DataSnapshot else { return }
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
                
                allObjects.forEach { snapshot in
                    
                    let notificationId = snapshot.key
                    
                    if notificationId != self.currentKey {
                        self.fetchNotifications(withNotificationId: notificationId, dataSnapshot: snapshot)
                    }
                }
                self.currentKey = first.key
            }
        }
    }
    
    private func fetchNotifications(withNotificationId notificationId: String, dataSnapshot snapshot: DataSnapshot) {
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else { return }
        guard let uid = dictionary["uid"] as? String else { return }

        Database.fetchUser(with: uid) { user in

            // if notification is for post
            if let postId = dictionary["postId"] as? String {
                Database.fetchPost(with: postId) { post in
                    let notification = Notification(user: user, post: post, dictionary: dictionary)
                    self.notifications.append(notification)
                    self.handleReloadTable()
                }
            } else {
                let notification = Notification(user: user, dictionary: dictionary)
                self.notifications.append(notification)
                self.handleReloadTable()
            }
        }
        NOTIFICATIONS_REF.child(currentUid).child(notificationId).child("checked").setValue(1)
    }
}



// MARK: - Delegate
extension NotificationVC: NotificationCellDelegate {
    
    func handleFollowTapped(for cell: NotificationCell) {
        guard let user = cell.notification?.user else { return }
        
        if user.isFollowed {
            user.unfollow()
            cell.followButton.configure(didFollow: false)
        } else {
            user.follow()
            cell.followButton.configure(didFollow: true)
        }
    }
    // notification에서 post를 누르면 해당 post로 이동(1개)
    func handlePostTapped(for cell: NotificationCell) {
        guard let post = cell.notification?.post else { return }
        
        let feedController = FeedVC(collectionViewLayout: UICollectionViewFlowLayout())
            feedController.post = post
            feedController.modalPresentationStyle = .fullScreen
            feedController.viewSinglePost = true
        self.navigationController?.pushViewController(feedController, animated: true)
    }
}
