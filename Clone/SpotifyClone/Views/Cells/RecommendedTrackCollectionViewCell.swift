//
//  RecommendedTrackCollectionViewCell.swift
//  SpotifyClone
//
//  Created by Rj O'Neal on 5/21/23.
//

import UIKit

protocol RecommendedTrackCollectionViewCellDelegate: AnyObject
{
    func recommendedTrackCollectionViewCellDidSwipeToDelete(_ cell: RecommendedTrackCollectionViewCell)
}

class RecommendedTrackCollectionViewCell: UICollectionViewCell
{
    static let identifier = "RecommendedTrackCollectionViewCell"
    
    private let albumCoverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "photo")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let trackNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.numberOfLines = 0
        return label
    }()
    
    private let artistNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .light)
        label.numberOfLines = 0
        return label
    }()
    
    weak var delegate: RecommendedTrackCollectionViewCellDelegate?

    private lazy var panGestureRecoginizer: UIPanGestureRecognizer = {
          let recognizer = UIPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
          recognizer.delegate = self
          return recognizer
      }()
    
    private let deleteLabel:UILabel = {
        let label = UILabel()
        label.text = "Delete"
        label.textColor = .white
        label.backgroundColor = .red
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        contentView.backgroundColor = .secondarySystemBackground
        contentView.addSubview(albumCoverImageView)
        contentView.addSubview(trackNameLabel)
        contentView.addSubview(artistNameLabel)
      
        contentView.clipsToBounds = true
        backgroundColor = .red
        addSubview(deleteLabel)
        deleteLabel.translatesAutoresizingMaskIntoConstraints = false
        deleteLabel.textAlignment = .center
    }
    
    required init?(coder: NSCoder)
    {
        fatalError()
    }
    
    public func addGesture()
    {
        addGestureRecognizer(panGestureRecoginizer)
    }
    override func layoutSubviews()
    {
        super.layoutSubviews()
        let imageViewDimension = contentView.height - 4
        
        albumCoverImageView.frame = CGRect(x: 5, y: 2, width: imageViewDimension, height:imageViewDimension)
        
        
        trackNameLabel.frame = CGRect(x: albumCoverImageView.right + 10,
                                      y: 0,
                                      width: contentView.width - albumCoverImageView.right - 15,
                                      height: contentView.height / 2)
        
        artistNameLabel.frame = CGRect(x: albumCoverImageView.right+10,
                                       y: trackNameLabel.bottom + 5 ,
                                       width: contentView.width-albumCoverImageView.right - 15,
                                       height: contentView.height/2)
        
        deleteLabel.frame = CGRect(x: contentView.frame.width + 100, y: 0, width: 100, height: contentView.frame.height)


    }
    override func prepareForReuse()
    {
        super.prepareForReuse()
        trackNameLabel.text = nil
        albumCoverImageView.image = nil
        artistNameLabel.text = nil
    }
    
    func configure(with viewModel: RecommendedTrackCellViewModel)
    {
        trackNameLabel.text = "" + viewModel.name + ""
        albumCoverImageView.sd_setImage(with: viewModel.artworkURL, completed: nil)
        artistNameLabel.text = viewModel.artistName
    }
}

extension RecommendedTrackCollectionViewCell: UIGestureRecognizerDelegate
{
    @objc func onPan(_ pan: UIPanGestureRecognizer)
       {
           switch pan.state {
           case .began:
               break
           case .changed:
               let translation = pan.translation(in: self)
               if translation.x > 0{return}
               self.contentView.center = CGPoint(x: self.contentView.center.x + translation.x, y: self.contentView.center.y)
               pan.setTranslation(CGPoint.zero, in: self)
               deleteLabel.frame.origin.x = contentView.frame.maxX - deleteLabel.frame.width
           case .ended:
               let cellCenterInCell = convert(contentView.center, from: contentView.superview)
               if !bounds.contains(cellCenterInCell) {
                   delegate?.recommendedTrackCollectionViewCellDidSwipeToDelete(self)
               } else {
                   UIView.animate(withDuration: 0.2) { [weak self] () in
                       self?.contentView.frame = self?.bounds ?? CGRect()
                       self?.deleteLabel.transform = .identity
                       self?.deleteLabel.frame = CGRect(x: (self?.contentView.frame.width ?? 0) + 100 ?? 0, y: 0, width: 100, height: self?.contentView.frame.height ?? 0)
                   }
               }
           default:
               UIView.animate(withDuration: 0.2) { [weak self] () in
                   self?.contentView.frame = self?.bounds ?? CGRect()
                   self?.deleteLabel.transform = .identity
                   self?.deleteLabel.frame = CGRect(x: (self?.contentView.frame.width ?? 0) + 100 ?? 0, y: 0, width: 100, height: self?.contentView.frame.height ?? 0)
               }
           }
       }

    
}
