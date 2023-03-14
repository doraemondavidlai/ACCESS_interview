//
//  GitUserDetailViewController.swift
//  ACCESS_interview
//
//  Created by 賴永峰 on 2023/3/14.
//

import UIKit
import CoreData

fileprivate enum DetailRows: Int, CaseIterable {
  case Avatar                   = 0
  case LoginName
  case Location
  case Blog
}

class GitUserDetailViewController: UIViewController {
  @IBOutlet weak var tableView: UITableView!
  
  var userID: Int64!
  fileprivate var userFRC: NSFetchedResultsController<GitUser>!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
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
    
    userFRC = GitUserHandler.getUserFRC(userID: userID)
    userFRC.delegate = self
    
    if (userFRC.fetchedObjects?.count ?? 0) > 0,
       let user = userFRC.fetchedObjects?[0],
       user.name == nil,
       let loginName = user.login {
      NetworkController.shared.getUserDetail(loginName: loginName)
    }
  }
  
  
  @IBAction func dismissAction(_ sender: Any) {
    dismiss(animated: true)
  }
  
  
}

extension GitUserDetailViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return DetailRows.allCases.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    var userObject: GitUser? = nil
    
    if (userFRC.fetchedObjects?.count ?? 0) > 0,
       let user = userFRC.fetchedObjects?[0] {
      userObject = user
    }
    
    switch DetailRows(rawValue: indexPath.row)! {
    case .Avatar:
#warning("implement: new cell")
      let cell = tableView.dequeueReusableCell(withIdentifier: "GitUserTableViewCell") as! GitUserTableViewCell
      if let avatarImageSrc = userObject?.avatarUrl,
         let avatarUrl = URL(string: avatarImageSrc) {
        cell.display(url: avatarUrl)
      }
      
      cell.loginLabel.text = userObject?.name
      cell.numberLabel.text = userObject?.bio
      cell.badgeLabel.isHidden = true
      cell.accessoryType = .none
      cell.selectionStyle = .none
      cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: UIScreen.main.bounds.width)
      return cell
      
    case .LoginName:
      let cell = tableView.dequeueReusableCell(withIdentifier: "GitUserTableViewCell") as! GitUserTableViewCell
      cell.userAvatarImageView.image = UIImage(systemName: "person.fill")
      cell.userAvatarImageView.tintColor = .darkGray
      cell.numberLabel.isHidden = true
      cell.accessoryType = .none
      cell.selectionStyle = .none
      cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: UIScreen.main.bounds.width)
      
      cell.loginLabel.text = userObject?.login
      cell.badgeLabel.isHidden = userObject?.isSiteAdmin == 0
      return cell
      
    case .Location:
      let cell = tableView.dequeueReusableCell(withIdentifier: "GitUserTableViewCell") as! GitUserTableViewCell
      cell.userAvatarImageView.image = UIImage(systemName: "mappin.and.ellipse")
      cell.userAvatarImageView.tintColor = .darkGray
      cell.numberLabel.isHidden = true
      cell.accessoryType = .none
      cell.selectionStyle = .none
      cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: UIScreen.main.bounds.width)
      
      cell.loginLabel.text = userObject?.location
      cell.badgeLabel.isHidden = true
      return cell
      
    case .Blog:
#warning("implement: link url")
      let cell = tableView.dequeueReusableCell(withIdentifier: "GitUserTableViewCell") as! GitUserTableViewCell
      cell.userAvatarImageView.image = UIImage(systemName: "link")
      cell.userAvatarImageView.tintColor = .darkGray
      cell.numberLabel.isHidden = true
      cell.accessoryType = .none
      cell.selectionStyle = .none
      cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: UIScreen.main.bounds.width)
      
      cell.loginLabel.text = userObject?.blog
      cell.badgeLabel.isHidden = true
      return cell
    }
  }
}

extension GitUserDetailViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    switch DetailRows(rawValue: indexPath.row)! {
    case .Avatar:
      return 300.0
      
    default:
      return 80.0
    }
  }
}

extension GitUserDetailViewController: NSFetchedResultsControllerDelegate {
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    tableView.reloadData()
  }
}
