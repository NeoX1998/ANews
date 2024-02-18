//
//  NewsTableViewCell.swift
//  ANews
//
//  Created by 許博皓 on 2023/7/12.
//

import UIKit

class NewsTableViewCell: UITableViewCell {

    @IBOutlet var titleLabel: UILabel! {
        didSet { //避免文字被截掉
            titleLabel.numberOfLines = 0
        }
    }
    @IBOutlet var newsImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
