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
    
    
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // delegate
        self.delegate = self
        
        self.configureViewControllers()
        
        // configure notification dot
        self.configureNotificationDot()
        
        // observe notifications dot
        self.observeNotifications()
        
        // 로그인이 된 상태인 지 확인
            // 로그인 된 상태 : 화면 구성(tabBar의 1번째, -> feedVC로 이동)
            // 로그인이 안 된 상태 : loginVC로 present
        self.checkIfUserIsLoggedIn()
    }
    
    
    
    // MARK: - Helper Functions
    // function to create view controllers that exist within tab bar controller
    // tab bar controller를 만듦
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
    // navigation Bar 설정
    private func constructNavController(UnselectedImage: UIImage, selectedImage: UIImage, rootViewController: UIViewController = UIViewController()) -> UINavigationController {
        
        // construct nav controller
        let navController = UINavigationController(rootViewController: rootViewController)
            navController.tabBarItem.image = UnselectedImage
            navController.tabBarItem.selectedImage = selectedImage
            navController.navigationBar.tintColor = .black
        return navController
    }
    
    // notification_tab_Bar 밑에 알림 바 설정
        // 이건 refactoring 해야 할 듯
    // 알림 표시
    private func configureNotificationDot() {
        if UIDevice().userInterfaceIdiom == .phone {
            let tabBarHeight = tabBar.frame.height
            
            self.dot.frame = CGRect(x: view.frame.width / 5 * 3,
                                    y: view.frame.height - tabBarHeight,
                                    width: 6,
                                    height: 6)
            
            self.dot.clipsToBounds = true
            self.dot.layer.cornerRadius = dot.frame.width / 2
            self.dot.center.x = (view.frame.width / 5 * 3 + (view.frame.width / 5) / 2)
            
            self.dot.backgroundColor = UIColor(red: 233/255, green: 30/255, blue: 99/255, alpha: 1)

            self.view.addSubview(dot)
            self.dot.isHidden = true
        }
    }
    
    
    
    // MARK: - UIBabBarController
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let index = viewControllers?.firstIndex(of: viewController)

        // selectedImageVC를 클릭하면
            // 화면 이동 (present)
        if index == 2 {
            let selectIamgeVC = SelectImageVC(collectionViewLayout: UICollectionViewFlowLayout())
            let navController = UINavigationController(rootViewController: selectIamgeVC)
                navController.modalPresentationStyle = .fullScreen
                navController.navigationBar.tintColor = .black
            self.present(navController, animated: true, completion: nil)
            
            return false
            // notificationVC를 클릭하면,
        } else if index == 3 {
            self.dot.isHidden = true
            return true
        }
        return true
    }
    
    
    
    // MARK: - API
    // 로그인이 된 상태인지 확인하는 함수
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
        
        // MainTabVC에 들어오면 DB_notification에서 데이터를 가져옴 (observe)
            // observe이기 때문에 notification에 알림이 생기면 다시 dot 생성
        NOTIFICATIONS_REF.child(currentUid).observe(.value) { snapshot in
            guard let allObject = snapshot.children.allObjects as? [DataSnapshot] else { return }
            
            allObject.forEach { snapshot in
                let notificationId = snapshot.key
                // 각각의 알림들의 'check'부분을 하나하나씩 보면서 체크 (observeSingleEvent)
                    // 'check'가 0인 경우 "알림을 확인하지 않았다."라는 뜻 -> dot 표시
                    // 'check'가 1인 경우 "알림을 확인 하였다"라는 뜻 -> dot 숨기기
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
