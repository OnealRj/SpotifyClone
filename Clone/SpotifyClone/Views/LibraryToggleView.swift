//
//  LibraryToggleView.swift
//  SpotifyClone
//
//  Created by Rj O'Neal on 6/2/23.
//

import UIKit

protocol LibraryToggleViewDelegate: AnyObject
{
    func toggleViewDidTapPlaylistButton(_ toggleView: LibraryToggleView)
    func toggleViewDidTapAlbumsButton(_ toggleView: LibraryToggleView)
}

class LibraryToggleView: UIView
{
    enum State
    {
        case playlist
        case album
    }
    
    var state: State = .playlist
    
    private let playlistButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.label, for: .normal)
        button.setTitle("Playlist", for: .normal)
        return button
    }()
    
    private let albumsButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.label, for: .normal)
        button.setTitle("Albums", for: .normal)
        return button
    }()
    
    private let indicatorView: UIView =
    {
        let view = UIView()
        view.backgroundColor = .systemGreen
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 4
        return view
    }()
    
    weak var delegate: LibraryToggleViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(playlistButton)
        addSubview(albumsButton)
        addSubview(indicatorView)
        
        self.playlistButton.addTarget(self,
                                      action: #selector(didTapPlaylists),
                                      for: .touchUpInside)
        
        self.albumsButton.addTarget(self,
                                      action: #selector(didTapAlbums),
                                      for: .touchUpInside)
        
        
    }
    @objc private func didTapPlaylists()
    {
        state = .playlist
        UIView.animate(withDuration: 0.2)
        {
            self.layoutIndicator()
        }
        delegate?.toggleViewDidTapPlaylistButton(self)
    }
    
    @objc private func didTapAlbums()
    {
        state = .album
        UIView.animate(withDuration: 0.2)
        {
            self.layoutIndicator()
        }
        delegate?.toggleViewDidTapAlbumsButton(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        playlistButton.frame = CGRect(x: 0,
                                           y: 0,
                                           width: 100,
                                           height: 40)
        albumsButton.frame = CGRect(x: playlistButton.right,
                                           y: 0,
                                           width: 100,
                                           height: 40)
        
        layoutIndicator()
        
       
    }
    private func layoutIndicator()
    {
        switch self.state{
        case .playlist:
            indicatorView.frame = CGRect(x: 0,
                                         y:playlistButton.bottom, width: 100, height: 3)
        case .album:
            indicatorView.frame = CGRect(x: 100,
                                         y:albumsButton.bottom, width: 100, height: 3)
        }
    }
    func update(for state: State)
    {
        self.state = state
        UIView.animate(withDuration: 0.2)
        {
            self.layoutIndicator()
        }
    }

}
