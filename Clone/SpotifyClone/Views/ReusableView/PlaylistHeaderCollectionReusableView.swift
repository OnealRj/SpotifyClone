//
//  PlaylistHeaderCollectionReusableView.swift
//  SpotifyClone
//
//  Created by Rj O'Neal on 5/26/23.
//

import UIKit
import SDWebImage

protocol PlaylistHeaderCollectionReusableViewDelegate: AnyObject
{
    func PlaylistHeaderCollectionReusableViewDidTapPlayAll(_ header: PlaylistHeaderCollectionReusableView)
}

class PlaylistHeaderCollectionReusableView: UICollectionReusableView {
    static let identifer = "PlaylistHeaderCollectionReusableView"
    
    weak var delegate: PlaylistHeaderCollectionReusableViewDelegate?
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()
    
    private let ownerLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .light)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let playlistImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(systemName: "photo")
        return imageView
    }()
    
    private let playAllButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemGreen
        let image = UIImage(systemName: "play.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 40, weight: .regular))
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.layer.cornerRadius = 30
        button.layer.masksToBounds = true
        return button
    }()
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .systemBackground
        addSubview(playlistImageView)
        addSubview(nameLabel)
        addSubview(descriptionLabel)
        addSubview(ownerLabel)
        addSubview(playAllButton)
        playAllButton.addTarget(self, action: #selector(didTapPlayAll), for: .touchUpInside)
    }
    
    @objc private func didTapPlayAll()
    {
        delegate?.PlaylistHeaderCollectionReusableViewDidTapPlayAll(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        // height of image
        let imageSize: CGFloat = height / 1.8
        
        playlistImageView.frame = CGRect(x: (width - imageSize) / 2,
                                         y: 20,
                                         width: imageSize,
                                         height: imageSize)
        nameLabel.frame = CGRect(x: 10,
                                 y: playlistImageView.bottom,
                                 width: width - 20,
                                 height: 44)
        
        descriptionLabel.frame = CGRect(x: 10,
                                 y: nameLabel.bottom,
                                 width: width - 20,
                                 height: 44)
        
        ownerLabel.frame = CGRect(x: 10,
                                 y: descriptionLabel.bottom,
                                 width: width - 20,
                                 height: 44)
        
        playAllButton.frame = CGRect(x: width - 70, y: height - 65, width: 60, height: 60)
        
    }
    
    func configure(with viewModel:PlaylistHeaderViewViewModel)
    {
        self.nameLabel.text  = viewModel.name
        self.ownerLabel.text = viewModel.owner
        self.descriptionLabel.text = viewModel.description
        self.playlistImageView.sd_setImage(with: viewModel.artworkURL,
                                           placeholderImage: UIImage(systemName: "photo"), completed: nil)
    }
        
}
