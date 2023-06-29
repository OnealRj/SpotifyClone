//
//  TitleHeaderCollectionReusableView.swift
//  SpotifyClone
//
//  Created by Rj O'Neal on 5/26/23.
//

import UIKit

class TitleHeaderCollectionReusableView: UICollectionReusableView
{
    static let identifier = "TitleHeaderCollectionReusableView"
    
    private let headerLabel: UILabel =
    {
        let label = UILabel()
        label.textColor = .label
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 22, weight: .regular)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        addSubview(headerLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.headerLabel.frame = CGRect(x: 15,
                                        y: 0,
                                        width: width - 30,
                                        height: height)
    }
    
    func configure(with title: String)
    {
        self.headerLabel.text = title
    }
        
}
