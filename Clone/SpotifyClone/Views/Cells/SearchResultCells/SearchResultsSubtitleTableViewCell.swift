//
//  SearchResultsSubtitleTableViewCell.swift
//  SpotifyClone
//
//  Created by Rj O'Neal on 5/31/23.
//

import UIKit
import SDWebImage
class SearchResultsSubtitleTableViewCell: UITableViewCell
{
    static let identifier = "SearchResultsSubtitleTableViewCell"
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        return label
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.window?.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label)
        contentView.addSubview(iconImageView)
        contentView.addSubview(subtitleLabel)
        contentView.clipsToBounds = true
        accessoryType = .disclosureIndicator
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        let imageSize: CGFloat = contentView.height - 10
        let labelHeight = contentView.height / 2
        iconImageView.frame = CGRect(x: 10,
                                     y: 5,
                                     width: imageSize,
                                     height: imageSize)
        
        label.frame = CGRect(x: iconImageView.right + 10,
                             y: 0,
                             width: contentView.width - iconImageView.right,
                             height: labelHeight)
        
        subtitleLabel.frame = CGRect(x: iconImageView.right + 10 ,
                                     y: label.bottom,
                                     width: contentView.width - iconImageView.right,
                                     height: labelHeight)
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.iconImageView.image = nil
        self.label.text = nil
        self.subtitleLabel.text = nil
    }
    
    func configure(with viewModel: SearchResultsSubtitleTableViewCellViewModel)
    {
        self.label.text = viewModel.title
        self.subtitleLabel.text = viewModel.subtitle
        self.iconImageView.sd_setImage(with: viewModel.imageURL,
                                      placeholderImage: UIImage(systemName: "photo"),
                                      completed: nil)
    }
}

