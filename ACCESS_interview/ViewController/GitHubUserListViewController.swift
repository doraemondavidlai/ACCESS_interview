//
//  GitHubUserListViewController.swift
//  ACCESS_interview
//
//  Created by 賴永峰 on 2023/3/13.
//

import UIKit
import CoreData

class GitHubUserListViewController: UIViewController {
  @IBOutlet weak var toolBar: UIToolbar!
  @IBOutlet weak var tableView: UITableView!
  
  fileprivate var refreshControl: UIRefreshControl!
  fileprivate var userFRC: NSFetchedResultsController<GitUser>!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor.black.withAlphaComponent(0.1)
    
    tableView.register(UINib(nibName: "GitUserTableViewCell", bundle: nil), forCellReuseIdentifier: "GitUserTableViewCell")
    tableView.tableHeaderView = UIView(frame: CGRect(x: 0,
                                                     y: 0,
                                                     width: tableView.frame.width,
                                                     height: CGFloat.leastNormalMagnitude))
    tableView.tableFooterView = UIView()
    tableView.backgroundColor = .clear
    tableView.delegate = self
    tableView.dataSource = self
    tableView.separatorStyle = .none
    tableView.layer.shadowColor = UIColor.black.withAlphaComponent(0.5).cgColor
    tableView.layer.shadowOffset = CGSize(width: 0.5, height: 1.0)
    tableView.layer.shadowOpacity = 0.4
    tableView.layer.shadowRadius = 2.0
    
    // toolBar
    let clearItem = UIBarButtonItem(title: "Clear All", image: nil, target: self, action: #selector(clearAllUser))
    let spaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
    let initialItem = UIBarButtonItem(title: "Re-initial", image: nil, target: self, action: #selector(refetchUsers))
    
    toolBar.setItems([clearItem, spaceItem, initialItem], animated: false)
    toolBar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
    toolBar.backgroundColor = nil
    toolBar.clipsToBounds = true
    
    refreshControl = UIRefreshControl()
    tableView.addSubview(refreshControl)
    
    userFRC = GitUserHandler.getUserFRC()
    userFRC.delegate = self
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    NetworkController.shared.getUserList(since: 0)
  }
  
  @objc func clearAllUser() {
    GitUserHandler.deleteAllData()
  }
  
  @objc func refetchUsers() {
    NetworkController.shared.getUserList(since: 0)
  }
}

extension GitHubUserListViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return userFRC.fetchedObjects?.count ?? 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "GitUserTableViewCell") as! GitUserTableViewCell
    
    guard let userObject = userFRC.fetchedObjects?[indexPath.row] as? GitUser else {
      return cell
    }
    
    cell.loginLabel.text = userObject.login
    cell.badgeLabel.isHidden = userObject.isSiteAdmin == 0
    cell.numberLabel.text = "\(indexPath.row)"
    
    if let avatarImageSrc = userObject.avatarUrl,
       let avatarUrl = URL(string: avatarImageSrc) {
      cell.display(url: avatarUrl)
    }
    
    cell.accessoryType = .none
    cell.selectionStyle = .none
    cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: UIScreen.main.bounds.width)
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 70.0
  }
}

extension GitHubUserListViewController: UITableViewDelegate {
  
}

extension GitHubUserListViewController: NSFetchedResultsControllerDelegate {
  func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    tableView.beginUpdates()
  }
  
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    switch type {
    case .insert:
      tableView.insertRows(at: [newIndexPath!], with: .right)
      
    case .delete:
      tableView.deleteRows(at: [indexPath!], with: .fade)
      
    case .update:
      tableView.reloadRows(at: [indexPath!], with: .none)
      
    default:
      break
    }
  }
  
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    tableView.endUpdates()
//    tableView.reloadData()
  }
}
