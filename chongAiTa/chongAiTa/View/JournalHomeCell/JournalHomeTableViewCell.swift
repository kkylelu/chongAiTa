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
        setupUI()
        selectionStyle = .none
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let cellMargins = CGFloat(16)
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: cellMargins, left: cellMargins, bottom: 0, right: cellMargins))
        
    }
    
    
    func setupUI(){
        contentView.layer.cornerRadius = 10
        contentView.clipsToBounds = true
        
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 6
        layer.masksToBounds = false
        
        contentView.backgroundColor = .white
        self.backgroundColor = .clear
        
    }
    
    func configure(with event: CalendarEvents) {
        timeLabel.text = DateFormatter.localizedString(from: event.date, dateStyle: .medium, timeStyle: .short)
        journalTitleLabel.text = event.title
        journalTitleLabel.baselineAdjustment = .alignCenters
        
        journalContentLabel.text = event.content
        JournalImageView.image = event.image
    }
}
