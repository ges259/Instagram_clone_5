//
//  MainTabVC.swift
//  InstagramCopy_5_0704
//
//  Created by 계은성 on 2023/07/05.
//

import UIKit
import FirebaseAuth

final class MainTabVC: UITabBarController, UITabBarControllerDelegate {
    
    
    
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // delegate
        self.delegate = self
        
        configureViewControllers()
        
        
        checkIfUserIsLoggedIn()
    }
    
    
    // function to create view controllers that exist within tab bar controller
    func configureViewControllers() {
        // home feed controller
        let feedVC = configureNavController(UnselectedImage: #imageLiteral(resourceName: "home_unselected"), selectedImage: #imageLiteral(resourceName: "home_selected"),
                                            rootViewController: FeedVC(collectionViewLayout: UICollectionViewFlowLayout()))
        // search feed controller
        let searchVC = configureNavController(UnselectedImage: #imageLiteral(resourceName: "search_unselected"), selectedImage: #imageLiteral(resourceName: "search_selected"),
                                              rootViewController: SearchVC())
        // post controler
        let uploadPostVC = configureNavController(UnselectedImage: #imageLiteral(resourceName: "plus_unselected"), selectedImage: #imageLiteral(resourceName: "save_shadow"),
                                                  rootViewController: UploadPostVC())
        // notification controller
        let notificationVC = configureNavController(UnselectedImage: #imageLiteral(resourceName: "like_unselected"), selectedImage: #imageLiteral(resourceName: "like_selected"),
                                                    rootViewController: NotificationsVC())
        // profile controller
        let userProfileVC = configureNavController(UnselectedImage: #imageLiteral(resourceName: "profile_unselected"), selectedImage: #imageLiteral(resourceName: "profile_selected"),
                                                   rootViewController: UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout()))
        
        // view controller to be added to tab controller
        self.viewControllers = [feedVC, searchVC, uploadPostVC, notificationVC, userProfileVC]
        
        // tab bar tint color
        self.tabBar.tintColor = .black
        
        
        
    }
    
    // construct navigation controllers
    private func configureNavController(UnselectedImage: UIImage, selectedImage: UIImage, rootViewController: UIViewController = UIViewController()) -> UINavigationController {
        
        
        // construct nav controller
        let navController = UINavigationController(rootViewController: rootViewController)
        
        navController.tabBarItem.image = UnselectedImage
        navController.tabBarItem.selectedImage = selectedImage
        navController.navigationBar.tintColor = .black
        
        
        
        
        return navController
    }
    
    
    
    
    
    
    private func checkIfUserIsLoggedIn() {
        
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {
                let loginVC = LoginVC()
                let navController = UINavigationController(rootViewController: loginVC)
                navController.modalPresentationStyle = .fullScreen
                self.present(navController, animated: true, completion: nil)
                
//                let loginVC = LoginVC()
//                loginVC.modalPresentationStyle = .fullScreen
//
//                self.present(loginVC, animated: true, completion: nil)

            }
            
        } else {
            print("user is logged in")
        }
        
        
        
        
    }
    
    
    
    
}
