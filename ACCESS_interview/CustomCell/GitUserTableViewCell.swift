//
//  GitUserTableViewCell.swift
//  ACCESS_interview
//
//  Created by 賴永峰 on 2023/3/13.
//

import UIKit

class GitUserTableViewCell: UITableViewCell {
  @IBOutlet weak var bgView: UIView!
  @IBOutlet weak var userAvatarImageView: UIImageView!
  @IBOutlet weak var indicator: UIActivityIndicatorView!
  @IBOutlet weak var numberLabel: UILabel!
  @IBOutlet weak var loginLabel: UILabel!
  @IBOutlet weak var badgeLabel: UILabel!
  @IBOutlet weak var badgeLabelWidthConstraint: NSLayoutConstraint!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    bgView.layer.cornerRadius = 5.0
    bgView.layer.masksToBounds = true
    
    let badgeText = "STAFF"
    let font = UIFont.systemFont(ofSize: 16.0, weight: .regular)
    badgeLabelWidthConstraint.constant = badgeText.width(withConstrainedHeight: 20.0, font: font) + 20.0
    badgeLabel.backgroundColor = .blue
    badgeLabel.textColor = .white
    badgeLabel.layer.cornerRadius = 10.0
    badgeLabel.layer.masksToBounds = true
  }
  
  func roundAvatarCorner() {
    userAvatarImageView.layer.cornerRadius = 20.0
    userAvatarImageView.layer.masksToBounds = true
  }
  
  func display(url: URL) {
    userAvatarImageView.image = nil
    indicator.startAnimating()
    
    DispatchQueue.global(qos: .default).async { [weak self] in
      guard let data = try? Data(contentsOf: url),
            let image = UIImage(data: data) else {
        return
      }
      
      DispatchQueue.main.async {
        self?.userAvatarImageView.image = image
        self?.indicator.stopAnimating()
        self?.layoutIfNeeded()
      }
    }
  }
}
