//
//  MainTabVC.swift
//  InstagramCopy_5_0704
//
//  Created by 계은성 on 2023/07/05.
//

import UIKit
import FirebaseAuth
import Firebase

final class MainTabVC: UITabBarController, UITabBarControllerDelegate {
    
    
    
    
    // MARK: - Properties
    let dot = UIView()
    var notificationIds = [String]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // delegate
        self.delegate = self
        
        configureViewControllers()
        
        // configure notification dot
        configureNotificationDot()
        
        // observe notifications dot
        observeNotifications()
        
        
        checkIfUserIsLoggedIn()
    }
    
    
    // function to create view controllers that exist within tab bar controller
    func configureViewControllers() {
        // home feed controller
        let feedVC = constructNavController(UnselectedImage: #imageLiteral(resourceName: "home_unselected"), selectedImage: #imageLiteral(resourceName: "home_selected"),
                                            rootViewController: FeedVC(collectionViewLayout: UICollectionViewFlowLayout()))
        // search feed controller
        let searchVC = constructNavController(UnselectedImage: #imageLiteral(resourceName: "search_unselected"), selectedImage: #imageLiteral(resourceName: "search_selected"),
                                              rootViewController: SearchVC())
        
        // selectImageVC controller
        let selectImageVC = constructNavController(UnselectedImage: #imageLiteral(resourceName: "plus_unselected"), selectedImage: #imageLiteral(resourceName: "plus_photo"))
        
        
        // notification controller
        let notificationVC = constructNavController(UnselectedImage: #imageLiteral(resourceName: "like_unselected"), selectedImage: #imageLiteral(resourceName: "like_selected"),
                                                    rootViewController: NotificationVC())
        // profile controller
        let userProfileVC = constructNavController(UnselectedImage: #imageLiteral(resourceName: "profile_unselected"), selectedImage: #imageLiteral(resourceName: "profile_selected"),
                                                   rootViewController: UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout()))
        
        // view controller to be added to tab controller
        self.viewControllers = [feedVC, searchVC, selectImageVC, notificationVC, userProfileVC]
        
        // tab bar tint color
        self.tabBar.tintColor = .black
        
        
        
    }
    // construct navigation controllers
    private func constructNavController(UnselectedImage: UIImage, selectedImage: UIImage, rootViewController: UIViewController = UIViewController()) -> UINavigationController {
        
        // construct nav controller
        let navController = UINavigationController(rootViewController: rootViewController)
        
        navController.tabBarItem.image = UnselectedImage
        navController.tabBarItem.selectedImage = selectedImage
        navController.navigationBar.tintColor = .black
        
        return navController
    }
    
    private func configureNotificationDot() {
        if UIDevice().userInterfaceIdiom == .phone {
            let tabBarHeight = tabBar.frame.height
            
            if UIScreen.main.nativeBounds.height == 2436 {
                // configure dot for iphone x
                dot.frame = CGRect(x: view.frame.width / 5 * 3, y: view.frame.height - tabBarHeight, width: 6, height: 6)
            } else {
                // configure dot for other phone models
                dot.frame = CGRect(x: view.frame.width / 5 * 3, y: view.frame.height - 16, width: 6, height: 6)
            }
            dot.center.x = (view.frame.width / 5 * 3 + (view.frame.width / 5) / 2)
            dot.backgroundColor = UIColor(red: 233/255, green: 30/255, blue: 99/255, alpha: 1)
            dot.layer.cornerRadius = dot.frame.width / 2
            dot.clipsToBounds = true
            self.view.addSubview(dot)
            dot.isHidden = true
        }
    }
    
    
    
    
    
    
    // MARK: - UIBabBarController
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let index = viewControllers?.firstIndex(of: viewController)

        if index == 2 {
            let selectIamgeVC = SelectImageVC(collectionViewLayout: UICollectionViewFlowLayout())
            let navController = UINavigationController(rootViewController: selectIamgeVC)
            navController.modalPresentationStyle = .fullScreen
            navController.navigationBar.tintColor = .black
            self.present(navController, animated: true, completion: nil)
            
            return false
        } else if index == 3 {
            dot.isHidden = true
            return true
        }
        return true
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    // MARK: - API
    private func checkIfUserIsLoggedIn() {
        
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {
                let loginVC = LoginVC()
                let navController = UINavigationController(rootViewController: loginVC)
                navController.modalPresentationStyle = .fullScreen
                self.present(navController, animated: true, completion: nil)
            }
        } else {
            print("user is logged in")
        }
    }
    
    
    private func observeNotifications() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        self.notificationIds.removeAll()
        
        NOTIFICATIONS_REF.child(currentUid).observeSingleEvent(of: .value) { snapshot in
            guard let allObject = snapshot.children.allObjects as? [DataSnapshot] else { return }
            
            allObject.forEach { snapshot in
                let notificationId = snapshot.key
                
                NOTIFICATIONS_REF.child(currentUid).child(notificationId).child("checked").observeSingleEvent(of: .value) { snapshot in
                    guard let checked = snapshot.value as? Int else { return }
                                        
                    if checked == 0 {
                        self.dot.isHidden = false
                    } else {
                        self.dot.isHidden = true
                    }
                }
            }
            
        }
    }
}
