//
//  GitUserDetailViewController.swift
//  ACCESS_interview
//
//  Created by 賴永峰 on 2023/3/14.
//

import UIKit
import CoreData

fileprivate enum GitUserDetailRows: Int, CaseIterable {
  case Avatar                   = 0
  case LoginName
  case Location
  case Blog
}

class GitUserDetailViewController: UIViewController {
  @IBOutlet weak var tableView: UITableView!
  
  var userID: Int64!
  fileprivate let vm = GitUserDetailViewModel()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.register(UINib(nibName: "AvatarTableViewCell", bundle: nil), forCellReuseIdentifier: "AvatarTableViewCell")
    tableView.register(UINib(nibName: "GitUserTableViewCell", bundle: nil), forCellReuseIdentifier: "GitUserTableViewCell")
    tableView.tableFooterView = UIView()
    tableView.backgroundColor = .clear
    tableView.delegate = self
    tableView.dataSource = self
    tableView.separatorStyle = .none
    
    vm.setFRC(id: userID)
    vm.userFRC.delegate = self
    vm.checkIsNeedToFetchDetail()
  }
  
  @IBAction func dismissAction(_ sender: Any) {
    dismiss(animated: true)
  }
  
  @objc func tapBlog(_ sender: UITapGestureRecognizer) {
    guard let url = vm.getBlogURL() else { return }
    UIApplication.shared.open(url, options: [:], completionHandler: nil)
  }
}

extension GitUserDetailViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return GitUserDetailRows.allCases.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let userObject: GitUser? = vm.getUserObject()
    
    switch GitUserDetailRows(rawValue: indexPath.row)! {
    case .Avatar:
      let cell = tableView.dequeueReusableCell(withIdentifier: "AvatarTableViewCell") as! AvatarTableViewCell
      cell.display(userObject?.avatarUrl)
      cell.nameLabel.text = userObject?.name
      cell.bioLabel.text = userObject?.bio
      
      cell.editNameAction = {
        let alert = UIAlertController(title: "Edit Name", message: nil, preferredStyle: .alert)
        
        alert.addTextField { (textField) in
          textField.placeholder = "New Name"
          textField.text = userObject?.name ?? ""
          textField.delegate = self
        }
        
        alert.addAction(UIAlertAction(title: "Update", style: .default, handler: { [weak alert] (_) in
          guard let textFieldsInAlert = alert?.textFields,
                textFieldsInAlert.count > 0,
                let inputText = textFieldsInAlert[0].text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            return
          }
          
          self.vm.updateUserName(inputText)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
      }
      
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
      
      cell.loginLabel.attributedText = NSAttributedString(string: userObject?.login ?? "")
      cell.loginLabel.isUserInteractionEnabled = false
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
      
      cell.loginLabel.attributedText = NSAttributedString(string: userObject?.location ?? "")
      cell.loginLabel.isUserInteractionEnabled = false
      cell.badgeLabel.isHidden = true
      return cell
      
    case .Blog:
      let cell = tableView.dequeueReusableCell(withIdentifier: "GitUserTableViewCell") as! GitUserTableViewCell
      cell.userAvatarImageView.image = UIImage(systemName: "link")
      cell.userAvatarImageView.tintColor = .darkGray
      cell.numberLabel.isHidden = true
      cell.accessoryType = .none
      cell.selectionStyle = .none
      cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: UIScreen.main.bounds.width)
      
      
      let blogWording: String = userObject?.blog ?? ""
      let blogAttributes: [NSAttributedString.Key: Any] = [.underlineStyle: NSUnderlineStyle.single.rawValue,
                                                           .foregroundColor: UIColor.link]
      cell.loginLabel.attributedText = NSAttributedString(string: blogWording, attributes: blogAttributes)
      
      cell.loginLabel.isUserInteractionEnabled = true
      cell.loginLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapBlog)))
      
      cell.badgeLabel.isHidden = true
      return cell
    }
  }
}

extension GitUserDetailViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    switch GitUserDetailRows(rawValue: indexPath.row)! {
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

extension GitUserDetailViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    return false
  }
}
