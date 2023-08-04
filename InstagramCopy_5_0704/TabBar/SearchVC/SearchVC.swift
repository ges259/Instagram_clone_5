//
//  SearchVC.swift
//  InstagramCopy_5_0704
//
//  Created by 계은성 on 2023/07/05.
//

import UIKit
import Firebase


private let collectionReuserIndetifier: String = "SearchPostCell"
private let tableViiewReuserIndetifier: String = "SearchUserCell"

final class SearchVC: UIViewController {
    
    // MARK: - Properties
    var users = [User]()
    
    // collection view
    var collectionView: UICollectionView!
    
    // table view
    var tableView: UITableView!
    
    // 서치바
    var searchBar = UISearchBar()
    var inSearchMode: Bool = false
    var filteredUsers = [User]()
    
    // 일부만 가져오기
    var postCurrentKey: String?
    var userCurrentKey: String?
    
    var posts = [Post]()
    
    
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // background color
        self.view.backgroundColor = .white
        
        // fetch posts
        self.fetchPosts()
        
        // configure search bar
        self.configureSearchBar()
        
        // configure table view
        self.configureTableView()
        self.tableView.isHidden = true
        
        // configure collection view
        self.configureCollectionView()
        self.collectionView.isHidden = false
        
        // configure refresh control
        self.configureRefreshControl()
        self.configureTableRefreshControl()
        
        // fetch users
        self.fetchUsers()
    }
    
    // MARK: - Selectors
    @objc func handleRefresh() {
        self.posts.removeAll(keepingCapacity: false)
        self.postCurrentKey = nil
        self.fetchPosts()
        self.collectionView.reloadData()
    }
    
    
    @objc func handleTableRefresh() {
        self.users.removeAll(keepingCapacity: false)
        self.userCurrentKey = nil
        self.fetchUsers()
        self.tableView.reloadData()
    }
    
    
    
    // MARK: - Helper Functions
    private func configureRefreshControl() {
        let refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        self.collectionView.refreshControl = refreshControl
    }
    
    
    private func configureTableRefreshControl() {
        let refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action: #selector(handleTableRefresh), for: .valueChanged)
        self.tableView.refreshControl = refreshControl
    }
    
    
    
    // MARK: - API
    private func fetchUsers() {
        if userCurrentKey == nil {
            
            USER_REF.queryLimited(toLast: 18).observeSingleEvent(of: .value) { snapshot in
                self.tableView.refreshControl?.endRefreshing()

                guard let first = snapshot.children.allObjects.first as? DataSnapshot else { return }
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
                
                allObjects.forEach { snapshot in
                    let userId = snapshot.key
                    
                    Database.fetchUser(with: userId) { user in
                        self.users.append(user)
                        self.tableView.reloadData()
                    }
                }
                self.userCurrentKey = first.key
            }
        } else {
            USER_REF.queryOrderedByKey().queryEnding(atValue: self.userCurrentKey).queryLimited(toLast: 24).observeSingleEvent(of: .value) { snapshot in
                
                guard let first = snapshot.children.allObjects.first as? DataSnapshot else { return }
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
                
                allObjects.forEach { snapshot in
                    let userId = snapshot.key
                    
                    if userId == self.userCurrentKey {
                        Database.fetchUser(with: userId) { user in
                            self.users.append(user)
                            self.tableView.reloadData()
                        }
                    }
                }
                self.userCurrentKey = first.key
            }
        }
    }
    
    private func fetchPosts() {
        
        if postCurrentKey == nil {
            // install data pull
            POSTS_REF.queryLimited(toLast: 21).observeSingleEvent(of: .value) { snapshot in
                
                self.collectionView.refreshControl?.endRefreshing()

                guard let first = snapshot.children.allObjects.first as? DataSnapshot else { return }
                guard let allObjcects = snapshot.children.allObjects as? [DataSnapshot] else { return }
                
                allObjcects.forEach { snapshot in
                    let postId = snapshot.key
                    
                    self.fetchPost(withPostId: postId)
                }
                self.postCurrentKey = first.key
            }
        } else {
            // paginate here
            POSTS_REF.queryOrderedByKey().queryEnding(atValue: self.postCurrentKey).queryLimited(toLast: 10).observeSingleEvent(of: .value) { snapshot in
                
                guard let first = snapshot.children.allObjects.first as? DataSnapshot else { return }
                guard let allObjcects = snapshot.children.allObjects as? [DataSnapshot] else { return }
                
                allObjcects.forEach { snapshot in
                    let postId = snapshot.key
                    
                    if postId != self.postCurrentKey {
                        self.fetchPost(withPostId: postId)
                    }
                }
                self.postCurrentKey = first.key
            }
        }
    }
    
    private func fetchPost(withPostId postId: String) {
        Database.fetchPost(with: postId) { post in
            self.posts.append(post)
            
            self.posts.sort { post1, post2 in
                return post1.creationDate > post2.creationDate
            }
            self.collectionView.reloadData()
        }
    }
}



// MARK: - Search Bar
extension SearchVC: UISearchBarDelegate {
    
    private func configureSearchBar() {
        self.searchBar.sizeToFit()
        self.searchBar.delegate = self
        self.navigationItem.titleView = searchBar
        self.searchBar.barTintColor = UIColor.rgb(red: 240, green: 240, blue: 240)
        self.searchBar.tintColor = .black
    }
    
    // 서치바가 시작되면 ( 취소버튼 표시
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        
        self.collectionView.isHidden = true
        self.tableView.isHidden = false
    }
    // 취소버튼을 눌렀을 때 (
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.endEditing(true)
        searchBar.text = nil
        
        self.inSearchMode = false
        
        self.collectionView.isHidden = false
        self.tableView.isHidden = true
    }
    
    // 텍스트를 적으면 불리는 메서드
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // hanle search text change
        let searchText = searchText.lowercased()
        
        if searchText.isEmpty || searchText == "" {
            self.inSearchMode = false
            self.tableView.reloadData()
        } else {
            self.inSearchMode = true
            self.filteredUsers = users.filter({ user in
                return user.userName.contains(searchText)
            })
            self.tableView.reloadData()
        }
    }
}



// MARK: - UICollectionView
extension SearchVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // datasource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionReuserIndetifier, for: indexPath) as! SearchPostCell
            cell.post = posts[indexPath.item]
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let feedVC = FeedVC(collectionViewLayout: UICollectionViewFlowLayout())
            feedVC.viewSinglePost = true
            feedVC.post = self.posts[indexPath.item]
        
        self.navigationController?.pushViewController(feedVC, animated: true)
    }
    
    private func configureCollectionView() {
        let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
        
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height - (tabBarController?.tabBar.frame.height)! - (navigationController?.navigationBar.frame.height)!)
        
        self.collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.alwaysBounceVertical = true
        self.collectionView.backgroundColor = .white
        
        self.collectionView.register(SearchPostCell.self, forCellWithReuseIdentifier: collectionReuserIndetifier)

        self.view.addSubview(self.collectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 2) / 3
        return CGSize(width: width, height: width)
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if posts.count > 26 {
            if indexPath.item == posts.count - 1 {
                self.fetchPosts()
            }
        }
    }
}


// MARK: - TabelView
extension SearchVC: UITableViewDelegate, UITableViewDataSource {
    
    private func configureTableView() {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        
        self.tableView = UITableView(frame: frame, style: .grouped)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.backgroundColor = .white
        self.tableView.separatorColor = .clear
        
        self.tableView.register(SearchUserCell.self, forCellReuseIdentifier: tableViiewReuserIndetifier)
        
        self.view.addSubview(self.tableView)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if users.count > 15 {
            if indexPath.row == users.count - 1 {
                self.fetchUsers()
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inSearchMode ? self.filteredUsers.count : users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: tableViiewReuserIndetifier, for: indexPath) as! SearchUserCell
        
            cell.user = self.inSearchMode ? self.filteredUsers[indexPath.row] : users[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        var user: User = self.inSearchMode ? self.filteredUsers[indexPath.row] : users[indexPath.row]
        
        // create instance of user profile vc
        let userProfileVC = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
        
        // passes user from searchVC to userProfileVC
            userProfileVC.user = user
//        userProfileVC.title = "Followers"
        // push view controller
        self.navigationController?.pushViewController(userProfileVC, animated: true)
    }
}
