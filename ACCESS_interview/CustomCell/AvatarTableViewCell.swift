//
//  AvatarTableViewCell.swift
//  ACCESS_interview
//
//  Created by 賴永峰 on 2023/3/14.
//

import UIKit

class AvatarTableViewCell: UITableViewCell {
  @IBOutlet weak var bigAvatarImageView: UIImageView!
  @IBOutlet weak var indicator: UIActivityIndicatorView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var bioLabel: UILabel!
  @IBOutlet weak var editNameButton: UIButton!
  
  var editNameAction: (() -> Void)?
  
  override func awakeFromNib() {
    super.awakeFromNib()
    bigAvatarImageView.layer.cornerRadius = 80.0
    bigAvatarImageView.layer.masksToBounds = true
  }
  
  @IBAction func triggerEditName(_ sender: Any) {
    editNameAction?()
  }
  
  func display(_ urlString: String?) {
    guard let avatarImageSrc = urlString,
          let avatarUrl = URL(string: avatarImageSrc) else {
      return
    }
    
    bigAvatarImageView.image = nil
    indicator.startAnimating()
    
    DispatchQueue.global(qos: .default).async { [weak self] in
      guard let data = try? Data(contentsOf: avatarUrl),
            let image = UIImage(data: data) else {
        return
      }
      
      DispatchQueue.main.async {
        self?.bigAvatarImageView.image = image
        self?.indicator.stopAnimating()
        self?.layoutIfNeeded()
      }
    }
  }
}
