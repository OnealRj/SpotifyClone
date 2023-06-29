//
//  FeaturedPlaylistCollectionViewCell.swift
//  SpotifyClone
//
//  Created by Rj O'Neal on 5/21/23.
//

import UIKit

class FeaturedPlaylistCollectionViewCell: UICollectionViewCell
{
    static let identifier = "FeaturedPlaylistCollectionViewCell"
    
    private let playlistCoverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "photo")
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 4
        return imageView
    }()
    
    private let playlistNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private let creatorNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .light)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        contentView.backgroundColor = .secondarySystemBackground
        contentView.addSubview(playlistCoverImageView)
        contentView.addSubview(playlistNameLabel)
        contentView.addSubview(creatorNameLabel)
        contentView.clipsToBounds = true
        
    }
    required init?(coder: NSCoder)
    {
        fatalError()
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        //Creator Name Label
        creatorNameLabel.frame = CGRect(x: 3,
                                        y: contentView.height - 30,
                                        width: contentView.width - 6,
                                        height: 30)
        
        //Playlist Name Label
        playlistNameLabel.frame = CGRect(x: 3,
                                         y: contentView.height - 60,
                                         width: contentView.height - 6,
                                         height: 30)
        
        //let imageSize = contentView.height
        let imageSize = contentView.height - 70
        playlistCoverImageView.frame = CGRect(x: (contentView.width - imageSize) / 2,
                                              y: 3,
                                              width: imageSize,
                                              height: imageSize)
        
    }
    
    override func prepareForReuse()
    {
        super.prepareForReuse()
        playlistNameLabel.text = nil
        playlistCoverImageView.image = nil
        creatorNameLabel.text = nil
    }
    
    func configure(with viewModel: FeaturedPlaylistCellViewModel)
    {
        playlistNameLabel.text = viewModel.name
        playlistCoverImageView.sd_setImage(with: viewModel.artworkURL, completed: nil)
        creatorNameLabel.text = viewModel.creatorName
    }
  
    
}
