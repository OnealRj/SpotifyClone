//
//  ActionLabelView.swift
//  SpotifyClone
//
//  Created by Rj O'Neal on 6/2/23.
//

import UIKit

struct ActionLabelViewViewModel
{
    let text:String
    let actionTitle:String
}

protocol ActionLabelViewDelegate: AnyObject
{
    func actionLabelViewDidTapButton(_ actionView: ActionLabelView)
}

class ActionLabelView: UIView {
    
    private let label:UILabel =
    {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let button:UIButton =
    {
        let button = UIButton()
        button.setTitleColor(.link , for: .normal)
        return button
    }()
    
    weak var delegate: ActionLabelViewDelegate?

    override init(frame: CGRect)
    {
        super.init(frame: frame)
        addSubview(button)
        addSubview(label)
        isHidden = true
        clipsToBounds = true
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    }
    
    @objc func didTapButton()
    {
        delegate?.actionLabelViewDidTapButton(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        button.frame = CGRect(x: 0,
                              y: height-40,
                              width: width,
                              height: 40)
        
        label.frame = CGRect(x: 0,
                             y: 0,
                             width: width,
                             height: height - 45)
        
        
    }
    
    func configure(with viewModel: ActionLabelViewViewModel)
    {
        label.text = viewModel.text
        button.setTitle(viewModel.actionTitle, for: .normal)
    }

}
