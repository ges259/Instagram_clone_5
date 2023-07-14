//
//  SearchVC.swift
//  InstagramCopy_5_0704
//
//  Created by 계은성 on 2023/07/05.
//

import UIKit
import Firebase


private let collectionreuserIndetifier: String = "SearchPostCell"

final class SearchVC: UIViewController, UISearchResultsUpdating {
    
    
    
    // MARK: - Properties
    var users = [User]()
    
    var inSearchMode: Bool = false
//    var tableView: UITableView!
    
    var collectionView: UICollectionView!
    var collectionViewEnabled: Bool = true
    
    
    var searchBar = UISearchBar()
    
    
    
    var resultSearchBar = UISearchController(searchResultsController: SearchResultVC())
    
    var posts = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        print("SearchVC")
        
        view.backgroundColor = .white
        
        // fetch posts
        self.fetchPosts()
        
        
        navigationItem.searchController = resultSearchBar
        resultSearchBar.searchResultsUpdater = self
        resultSearchBar.searchBar.autocapitalizationType = .none
        resultSearchBar.searchBar.autocorrectionType = .no
        
        
        
        // configure collection view
        self.configureCollectionView()
    }
    func updateSearchResults(for searchController: UISearchController) {
        
        let vc = searchController.searchResultsController as! SearchResultVC
        
        fetchUsers()
        vc.users = self.users
        
        vc.searchTerm = searchController.searchBar.text ?? ""
        
    }
    
    // MARK: - handler
    
    
    
    
    
    
    
    
    // MARK: - API
    private func fetchUsers() {
        // childAdded = 목록 가져오기
        USER_REF.observe(.childAdded) { snapshot in
            
            // uid
            let uid = snapshot.key
            
            Database.fetchUser(with: uid) { user in
                
                self.users.append(user)
            }
        }
    }
    
    private func fetchPosts() {
        
        posts.removeAll()
        
        POSTS_REF.observe(.childAdded) { snapshot in
            let postId = snapshot.key
            
            Database.fetchPost(with: postId) { post in
                self.posts.append(post)
                self.collectionView.reloadData()
            }
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionreuserIndetifier, for: indexPath) as! SearchPostCell
        
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
        
        collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .white
        
        
        
        
        collectionView.register(SearchPostCell.self, forCellWithReuseIdentifier: collectionreuserIndetifier)

        self.view.addSubview(collectionView)
//        tableView?.separatorColor = .clear
        
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
    
    
}
