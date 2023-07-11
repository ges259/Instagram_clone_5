//
//  NotificationsVC.swift
//  InstagramCopy_5_0704
//
//  Created by 계은성 on 2023/07/05.
//

import UIKit


private let reuseIdentifier: String = "NotificationCell"


final class NotificationVC: UITableViewController {
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(NotificationCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        self.tableView.separatorStyle = .none
        
        self.navigationItem.title = "Notifications"
        
    }
    
    
    
    
    
    
    
    
    // MARK: - DataSource
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 4
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as! NotificationCell
        
        return cell
    }
    
    
    
    
    
}



