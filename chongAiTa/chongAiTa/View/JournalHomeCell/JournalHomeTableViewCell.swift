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
    @IBOutlet weak var journalImageView: UIImageView!
    
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
        
        if #available(iOS 13.0, *) {
            contentView.backgroundColor = UIColor { (traitCollection) -> UIColor in
                switch traitCollection.userInterfaceStyle {
                case .dark:
                    return .black 
                default:
                    return .white
                }
            }
        } else {
            contentView.backgroundColor = .white
        }
        
    }
    
    func configure(with journal: Journal) {
        journalTitleLabel.text = journal.title
        
        // 設定預覽文字
        let previewText = journal.body.prefix(12)
        journalContentLabel.text = String(previewText) + "..."
        
        // 設定日期格式
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "zh_Hant_TW")
        dateFormatter.dateFormat = "yyyy 年 M 月 d 日 EEEE"
        timeLabel.text = dateFormatter.string(from: journal.date)
        
        // 設定圖片顯示
        journalImageView.contentMode = .scaleAspectFill
        journalImageView.clipsToBounds = true
        
        // 嘗試使用內建圖片，如果沒有，就使用 URL 載入
        if !journal.images.isEmpty {
            journalImageView.image = journal.images.first
            print("從內建圖庫載入圖片 '\(journal.title)'")
        } else if let imageURL = URL(string: journal.imageUrls.first ?? "") {
            journalImageView.kf.setImage(with: imageURL, placeholder: nil, options: [.transition(.fade(0.3))])
            print("從 URL 載入圖片 '\(journal.title)'")
        } else {
            journalImageView.image = nil
            print("沒有圖片可顯示 '\(journal.title)'")
        }
    }

    func configure(with event: CalendarEvents, formattedDate: String) {
        journalTitleLabel.text = event.title
        journalContentLabel.text = event.content
        timeLabel.text = formattedDate

        // 處理圖片
        journalImageView.contentMode = .scaleAspectFill
        journalImageView.clipsToBounds = true

        let iconName = event.activity.category.iconName
            if let image = UIImage(named: iconName) {
                journalImageView.image = image
                print("顯示圖片 '\(event.title)'")
            } else {
                journalImageView.image = UIImage(named: "Placeholder picture")
                print("沒有圖片可顯示 '\(event.title)'")
            }
    }
}
