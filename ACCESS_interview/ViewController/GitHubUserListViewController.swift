//
//  GitHubUserListViewController.swift
//  ACCESS_interview
//
//  Created by 賴永峰 on 2023/3/13.
//

import UIKit
import CoreData

fileprivate enum PullUpState {
  case PullHint
  case Release
}

class GitHubUserListViewController: UIViewController {
  @IBOutlet weak var toolBar: UIToolbar!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var pullUpStackView: UIStackView!
  @IBOutlet weak var pullUpImageView: UIImageView!
  @IBOutlet weak var pullUpHintLabel: UILabel!
  
  fileprivate let pullUpRevealHeight: CGFloat = 80.0
  fileprivate let dataLimit: Int = 100
  fileprivate var userFRC: NSFetchedResultsController<GitUser>!
  fileprivate var sinceUserID: Int = 0
  
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
    toolBar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
    toolBar.backgroundColor = nil
    toolBar.clipsToBounds = true
    
    pullUpStackView.alpha = 0.0
    setPullUpState(.PullHint)
    
    if let savedUserID = UserDefaults.standard.object(forKey: "SavedSinceUserID") as? Int {
      sinceUserID = savedUserID
    } else {
      sinceUserID = 0
    }
    
    userFRC = GitUserHandler.getUserFRC()
    userFRC.delegate = self
    
    // incase no data
    NetworkController.shared.getUserList(since: 0)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    NotificationCenter.default.addObserver(self, selector: #selector(setLastUserID), name: NotificationType.LastUserID.notificationName, object: nil)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    NotificationCenter.default.removeObserver(self, name: NotificationType.LastUserID.notificationName, object: nil)
  }
  
  @objc func clearAllUser() {
    setSinceUserID(0)
    GitUserHandler.deleteAllData()
  }
  
  @objc func refetchUsers() {
    setSinceUserID(0)
    NetworkController.shared.getUserList(since: sinceUserID)
  }
  
  fileprivate func setToolBar(_ userCount: Int) {
    let clearItem = UIBarButtonItem(title: "Clear All", image: nil, target: self, action: #selector(clearAllUser))
    let spaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
    let initialItem = UIBarButtonItem(title: "Re-initial", image: nil, target: self, action: #selector(refetchUsers))
    
    if userCount > 0 {
      toolBar.setItems([clearItem, spaceItem], animated: false)
    } else {
      toolBar.setItems([clearItem, spaceItem, initialItem], animated: false)
    }
  }
  
  fileprivate func setPullUpState(_ state: PullUpState) {
    switch state {
    case .PullHint:
      pullUpImageView.image = UIImage(systemName: "arrow.up")
      pullUpHintLabel.text = "Pull up to fetch more"
      
    case .Release:
      pullUpImageView.image = UIImage(systemName: "arrow.down.doc")
      pullUpHintLabel.text = "Release to fetch"
    }
  }
  
  fileprivate func checkItemReachLimit() -> Bool {
    return tableView(tableView, numberOfRowsInSection: 0) >= dataLimit
  }
  
  fileprivate func setSinceUserID(_ newUserID: Int) {
    sinceUserID = newUserID
    UserDefaults.standard.set(NSNumber(integerLiteral: newUserID), forKey: "SavedSinceUserID")
  }
}

extension GitHubUserListViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let count = userFRC.fetchedObjects?.count ?? 0
    setToolBar(count)
    return count
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
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
#warning("implement")
  }
}

extension GitHubUserListViewController: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if checkItemReachLimit() { return }
    
    let endScrolling = scrollView.contentOffset.y + scrollView.frame.size.height - 34.0
    
    let revealHeight = endScrolling - scrollView.contentSize.height
    var scale: CGFloat = revealHeight / 40.0
    
    if scale < 0 {
      scale = 0.0
    } else if scale > 1 {
      scale = 1.0
    }
    
    pullUpStackView.alpha = scale
    
    if revealHeight > pullUpRevealHeight {
      setPullUpState(.Release)
    } else {
      setPullUpState(.PullHint)
    }
  }
  
  func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    if checkItemReachLimit() { return }
    
    let endScrolling = scrollView.contentOffset.y + scrollView.frame.size.height - 34.0
    
    if endScrolling >= scrollView.contentSize.height + pullUpRevealHeight {
      NetworkController.shared.getUserList(since: sinceUserID)
    }
  }
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
    
    pullUpStackView.alpha = 0.0
    setPullUpState(.PullHint)
  }
}

// MARK - Observer
extension GitHubUserListViewController {
  @objc func setLastUserID(_ notification: Notification) {
    guard let passInDictionary = notification.userInfo as NSDictionary?,
          let lastID = passInDictionary.object(forKey: "lastID") as? Int else {
      print("error: notification.userInfo get msgType error!")
      return
    }
    
    setSinceUserID(lastID)
  }
}
