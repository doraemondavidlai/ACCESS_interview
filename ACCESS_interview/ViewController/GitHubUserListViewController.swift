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
  @IBOutlet weak var pullUpStackView: UIStackView!
  @IBOutlet weak var pullUpImageView: UIImageView!
  @IBOutlet weak var pullUpHintLabel: UILabel!
  
  fileprivate let vm = GitHubUserListViewModel()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor.black.withAlphaComponent(0.1)
    
    tableView.register(UINib(nibName: "GitUserTableViewCell", bundle: nil), forCellReuseIdentifier: "GitUserTableViewCell")
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
    
    vm.setFRC()
    vm.userListFRC.delegate = self
    vm.updateSinceUserIDFromFRC()
    
    // incase no data
    if vm.getFRCDataCount() < 1 {
      vm.getUserList(0)
    }
  }
  
  @objc func clearAllUser() {
    vm.deleteAllUser()
  }
  
  @objc func refetchUsers() {
    vm.getUserList()
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
      
    case .ReachLimit:
      pullUpImageView.image = UIImage(systemName: "hand.raised.fill")
      pullUpHintLabel.text = "Reach fetch limit \(vm.dataLimit)"
    }
  }
  
  fileprivate func checkItemReachLimit() -> Bool {
    return tableView(tableView, numberOfRowsInSection: 0) >= vm.dataLimit
  }
}

extension GitHubUserListViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let count = vm.getFRCDataCount()
    setToolBar(count)
    return count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "GitUserTableViewCell") as! GitUserTableViewCell
    cell.roundAvatarCorner()
    
    guard let userObject = vm.getFRCUserObject(at: indexPath.row) else {
      return cell
    }
    
    cell.display(userObject.avatarUrl)
    cell.loginLabel.text = userObject.login
    cell.badgeLabel.isHidden = userObject.isSiteAdmin == 0
    cell.numberLabel.text = "\(indexPath.row)"
    
    cell.accessoryType = .none
    cell.selectionStyle = .none
    cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: UIScreen.main.bounds.width)
    return cell
  }
}

extension GitHubUserListViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let userObject = vm.getFRCUserObject(at: indexPath.row) else {
      print("\(indexPath.row) can not get login name")
      return
    }
    
    let gitUserDetailVC = GitUserDetailViewController(nibName: "GitUserDetailViewController", bundle: nil)
    gitUserDetailVC.userID = userObject.userID
    present(gitUserDetailVC, animated: true)
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 70.0
  }
}

extension GitHubUserListViewController: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let homeIndicatorFix: CGFloat = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 34.0
    let endScrolling = scrollView.contentOffset.y + scrollView.frame.size.height - homeIndicatorFix
    
    let revealHeight = endScrolling - scrollView.contentSize.height
    var scale: CGFloat = revealHeight / 40.0
    
    if scale < 0 {
      scale = 0.0
    } else if scale > 1 {
      scale = 1.0
    }
    
    pullUpStackView.alpha = scale
    
    if checkItemReachLimit() {
      setPullUpState(.ReachLimit)
    } else if revealHeight > vm.pullUpRevealHeight {
      setPullUpState(.Release)
    } else {
      setPullUpState(.PullHint)
    }
  }
  
  func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    if checkItemReachLimit() { return }
    
    let homeIndicatorFix: CGFloat = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 34.0
    let endScrolling = scrollView.contentOffset.y + scrollView.frame.size.height - homeIndicatorFix
    
    if endScrolling >= scrollView.contentSize.height + vm.pullUpRevealHeight {
      vm.getUserList()
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
    
    vm.updateSinceUserIDFromFRC()
  }
}
