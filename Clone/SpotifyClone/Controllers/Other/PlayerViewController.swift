//
//  PlayerViewController.swift
//  SpotifyClone
//
//  Created by Rj O'Neal on 5/14/23.
//

import UIKit
import SDWebImage

protocol PlayerViewControllerDelegate: AnyObject
{
    func didTapPlayPause()
    func didTapBackward()
    func didTapForward()
    func didSlideSlider(_ value: Float)
}

class PlayerViewController: UIViewController
{
    weak var dataSource: PlayerDataSource?
    weak var delegate: PlayerViewControllerDelegate?
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let controlsView = PlayerControlsView()

    override func viewDidLoad()
    {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(imageView)
        view.addSubview(controlsView)
        controlsView.delegate = self
        configureBarButtons()
        configure()
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        imageView.frame = CGRect(x: 0,
                                 y: view.safeAreaInsets.top,
                                 width: view.width,
                                 height: view.width)
        
         
        controlsView.frame = CGRect(x: 10,
                                    y: imageView.bottom  + 10,
                                    width: view.width - 20,
                                    height: view.height - imageView.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom - 15)
    }
    private func configure() {
        self.imageView.sd_setImage(with: dataSource?.imageURL, completed: nil)
        self.controlsView.configure(with: PlayerControlsViewViewModel(title: dataSource?.songName,
                                                                      subtitle: dataSource?.subtitle))
        
    }
    
    private func configureBarButtons()
    {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(didTapClose))
        navigationItem.rightBarButtonItem  = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(didTapAction))
    }
    
    @objc private func didTapClose()
    {
        dismiss(animated: true)
    }
    
    @objc private func didTapAction()
    {
        // Actions
    }
    
    func refreshUI()
    {
        self.configure()
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}


extension PlayerViewController: PlayerControlsViewDelegate
{
    func playerControlsViewDidTapPlayPause(_ playerControlsView: PlayerControlsView)
    {
        delegate?.didTapPlayPause()
    }
    
    func playerControlsViewDidTapForwardButton(_ playerControlsView: PlayerControlsView) {
        delegate?.didTapForward()
        
    }
    
    func playerControlsViewDidTapBackwardButton(_ playerControlsView: PlayerControlsView)
    {
        delegate?.didTapBackward()
    }
    
    func playerControlsView(_ playerControlsView: PlayerControlsView, didSlideSlider value: Float)
    {
        delegate?.didSlideSlider(value)
    }
}
