//
//  GenreCollectionViewCell.swift
//  SpotifyClone
//
//  Created by Rj O'Neal on 5/28/23.
//

import UIKit
import SDWebImage

class CategoryCollectionViewCell: UICollectionViewCell
{
    static let identifier = "GenreCollectionViewCell"
    
    private let colors: [UIColor] = [
        .systemPink,
        .systemBlue,
        .systemPurple,
        .systemGreen,
        .systemRed,
        .systemYellow,
        .darkGray,
        .systemBrown
    ]
    
    private let imageView: UIImageView =
    {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        imageView.image = UIImage(systemName: "music.quarternote.3",
                                  withConfiguration: UIImage.SymbolConfiguration(pointSize: 50, weight: .regular))
        return imageView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.textColor = .white
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
        contentView.addSubview(imageView)
        contentView.addSubview(label)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        label.frame = CGRect(x: 10,
                             y: contentView.height / 2,
                             width: contentView.width-20,
                             height: contentView.height/2)
        imageView.frame = CGRect(x: contentView.width / 2,
                                 y: 10,
                                 width: contentView.width / 2,
                                 height: contentView.height / 2)
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
        imageView.image = UIImage(systemName: "music.quarternote.3",
                                  withConfiguration: UIImage.SymbolConfiguration(pointSize: 50, weight: .regular))
    }
    func configure(with viewModel:CategoryCollectionViewCellViewModel)
    {
        label.text = viewModel.title
        self.imageView.sd_setImage(with: viewModel.artworkURL, completed: nil)
        contentView.backgroundColor = colors.randomElement()
    }
    
}
