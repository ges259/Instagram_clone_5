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
    // CollectionView와 tableView를 미리 선언해놔야 함
        // UICollectionViewController / UITableViewController 를 사용하면 구현이 안 됐음
    // collection view
    var collectionView: UICollectionView!
    // table view
    var tableView: UITableView!
    
    // 일반 서치바
    var searchBar = UISearchBar()
    var inSearchMode: Bool = false
    // 검색어를 저장해둘 배열
    var filteredUsers = [User]()
    
    // 일부만 가져오기
        // 모든 사용자를 가져오는 것은 비효율적 (사용자가 100명이면 100명의 유저를 한 번에 다 가져와? <<-- 매우 비 효율적)
            // 먼저 18개를 가져옴
            // 사용자가 마지막 indexPath(17)를 볼 때 다시 fetchUsers / fetchPosts를 호출하여 24개를 가져옴
            // 하지만 다시 가져올 때 이미 앞에서 불린 사용자를 가져오면 안 되기 때문에 해당 함수를 사용하여 어디까지 불렸는지를 구분해줌.
    var postCurrentKey: String?
    var userCurrentKey: String?
    // API를 통해 가져온 post들을 담아둘 배열
    var posts = [Post]()
    
    
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // background color
        self.view.backgroundColor = .white
        
        // fetch users
        self.fetchUsers()
        
        // configure search bar
        self.configureSearchBar()
        
        // configure table view
        self.configureTableView()
        
        // configure collection view
        self.configureCollectionView()
        
        // configure refresh control
        self.configureRefreshControl()
        self.configureTableRefreshControl()
        
        // fetch posts
        self.fetchPosts()
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
            POSTS_REF.queryLimited(toLast: 17).observeSingleEvent(of: .value) { snapshot in
                
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
            POSTS_REF.queryOrderedByKey().queryEnding(atValue: self.postCurrentKey).queryLimited(toLast: 20).observeSingleEvent(of: .value) { snapshot in
                
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
    // fetchPosts에서 한정된 개수의 postId를 받아 DB에서 데이터를 가져온다.
    private func fetchPost(withPostId postId: String) {
        Database.fetchPost(with: postId) { post in
            // posts에 추가
            self.posts.append(post)
            // 날짜순 정렬
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
        self.searchBar.barTintColor = UIColor.customGray
        self.searchBar.tintColor = .black
    }
    
    // 서치바가 시작되면 ( 취소버튼 표시 )
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        
        self.collectionView.isHidden = true
        self.tableView.isHidden = false
    }
    // 취소버튼을 눌렀을 때
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
        return self.posts.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionReuserIndetifier, for: indexPath) as! SearchPostCell
            cell.post = self.posts[indexPath.item]
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
        
        // SearchVC에 들어오면 컬렉션뷰가 가장 먼저 보여야 하기 때문에 일단 false로 설정해 둠
            // SearchBar를 눌러서 tableView가 나올 때 true로 바뀜
        self.collectionView.isHidden = false
        
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
        // 처음에 fetchUsers()를 통해 17개의 post데이터를 가져옴.
            // SearchVC에 들어오면 fetchPosts()진행
                // -> 맨 처음에 이 함수가 불리면 안 되기 때문에 if문으로 막아둠
        if self.posts.count > 16 {
            // 셀을 하나씩 그리다가 17번째 셀을 그리면 ( 즉, indexPath.item가 16번째일 때 )
                // <- indexPath는 0부터 시작하기 때문에 posts.count에 -1을 해줌
            // 다시 fetchPosts()를 불러 20개의 user데이터들을 가져옴
                // 이후 posts.count는 20개가 되고, indexPath.item가 19번째 셀을 그릴 때 다시 fetchPosts()호출
                // 무한 반복.
            if indexPath.item == self.posts.count - 1 {
                self.fetchPosts()
            }
        }
    }
}



// MARK: - TabelView
extension SearchVC: UITableViewDelegate, UITableViewDataSource {
    
    private func configureTableView() {
        // tableView의 frame을 설정
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        // tableView 만들기
        self.tableView = UITableView(frame: frame, style: .grouped)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.backgroundColor = .white
        self.tableView.separatorColor = .clear
        // 컬렉션뷰가 먼저 보여야 하기 때문에 테이블뷰는 숨김
        self.tableView.isHidden = true
        
        self.tableView.register(SearchUserCell.self, forCellReuseIdentifier: tableViiewReuserIndetifier)
        
        self.view.addSubview(self.tableView)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // 처음에 fetchUsers()를 통해 18개의 user데이터를 가져옴.
            // SearchVC에 들어오면 fetchUsers()진행
                // -> 맨 처음에 이 함수가 불리면 안 되기 때문에 if문으로 막아둠
        if self.users.count > 17 {
            // 셀을 하나씩 그리다가 18번째 셀을 그리면 ( 즉, indexPath.row가 17번째일 때
                // <- indexPath는 0부터 시작하기 때문에 users.count에 -1을 해줌)
            // 다시 fetchUsers를 불러 24개의 user데이터들을 가져옴
                // 이후 users.count는 24개가 되고, indexPath.row가 23번째 셀을 그릴 때 다시 fetchUsers()호출
                // 무한 반복.
            if indexPath.row == users.count - 1 {
                self.fetchUsers()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inSearchMode ? self.filteredUsers.count : users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: tableViiewReuserIndetifier,
                                                 for: indexPath) as! SearchUserCell
            cell.user = self.inSearchMode
                ? self.filteredUsers[indexPath.row]
                : self.users[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let user: User = self.inSearchMode
            ? self.filteredUsers[indexPath.row]
            : self.users[indexPath.row]
        
        // create instance of user profile vc
        let userProfileVC = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
        
        // passes user from searchVC to userProfileVC
            userProfileVC.user = user
//        userProfileVC.title = "Followers"
        // push view controller
        self.navigationController?.pushViewController(userProfileVC, animated: true)
    }
}
