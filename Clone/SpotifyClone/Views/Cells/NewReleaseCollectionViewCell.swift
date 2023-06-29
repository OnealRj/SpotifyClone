//
//  NewReleaseCollectionViewCell.swift
//  SpotifyClone
//
//  Created by Rj O'Neal on 5/21/23.
//

import UIKit
import SDWebImage

//struct NewReleasesCellViewModel
//{
//    let name: String
//    let artworkURL: URL?
//    let numberOfTracks: Int
//    let artistName: String
//}


class NewReleaseCollectionViewCell: UICollectionViewCell {
    static let identifier = "NewReleaseCollectionViewCell"
    
    
    private let albumCoverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "photo")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let albumNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.numberOfLines = 0
        return label
    }()
    
    private let artistsNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.numberOfLines = 0
        return label
    }()
    
    private let numberOfTracksLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .thin)
        label.numberOfLines = 0
        return label
    }()

    
   

    override init(frame: CGRect)
    {
        super.init(frame: frame)
        contentView.backgroundColor = .secondarySystemBackground
        contentView.addSubview(albumCoverImageView)
        contentView.addSubview(albumNameLabel)
        contentView.addSubview(artistsNameLabel)
        contentView.clipsToBounds = true
        contentView.addSubview(numberOfTracksLabel)
    }
    
    required init?(coder: NSCoder)
    {
        fatalError()
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        let imageSize: CGFloat = contentView.height - 10
        let albumLabelSize = self.albumNameLabel.sizeThatFits(CGSize(width: contentView.width - imageSize - 10,
                                                                     height: contentView.height - 10))
        let albumLabelHeight = min(60,albumLabelSize.height)
        albumNameLabel.sizeToFit()
        artistsNameLabel.sizeToFit()
        numberOfTracksLabel.sizeToFit()
        
        
        albumCoverImageView.frame = CGRect(x:5, y:5, width: imageSize, height: imageSize)
        
       
        
        albumNameLabel.frame = CGRect(x: albumCoverImageView.right + 10,
                                      y:5,
                                            width: albumLabelSize.width,
                                            height: albumLabelHeight)
        
        
        artistsNameLabel.frame = CGRect(x: albumCoverImageView.right + 10,
                                        y: albumNameLabel.bottom + 5,
                                        width: contentView.width - albumCoverImageView.right - 10,
                                            height: 30)
        
        numberOfTracksLabel.frame = CGRect(x: albumCoverImageView.right + 10,
                                           y: contentView.bottom - 44,
                                           width: numberOfTracksLabel.width,
                                           height: 44)
    }
        
    
    override func prepareForReuse() {
        super.prepareForReuse()
        albumNameLabel.text = nil
        artistsNameLabel.text = nil
        numberOfTracksLabel.text = nil
        albumCoverImageView.image = nil
    }
    
    func configure(with viewModel: NewReleasesCellViewModel) {
        albumNameLabel.text = viewModel.name
        artistsNameLabel.text = viewModel.artistName
        numberOfTracksLabel.text = "Tracks: \(viewModel.numberOfTracks)"
        albumCoverImageView.sd_setImage(with: viewModel.artworkURL, completed: nil)
        
    }
}
