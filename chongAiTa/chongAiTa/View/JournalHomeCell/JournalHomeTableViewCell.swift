//
//  JournalHomeTableViewCell.swift
//  chongAiTa
//
//  Created by Kyle Lu on 2024/4/14.
//

import UIKit

class JournalHomeTableViewCell: UITableViewCell {

    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var journalTitleLabel: UILabel!
    @IBOutlet weak var journalContentLabel: UILabel!
    @IBOutlet weak var JournalImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
