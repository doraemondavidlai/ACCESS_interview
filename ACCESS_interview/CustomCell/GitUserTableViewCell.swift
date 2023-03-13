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
    
    
  }
  
  func display(url: URL) {
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
