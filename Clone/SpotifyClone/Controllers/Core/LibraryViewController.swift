//
//  LibraryViewController.swift
//  SpotifyClone
//
//  Created by Rj O'Neal on 5/14/23.
//

import UIKit
class LibraryViewController: UIViewController
{
    private let playlistsVC = LibraryPlaylistsViewController()
    private let albumsVC = LibraryAlbumsViewController()
    
    private let scrollView: UIScrollView =
    {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        return scrollView
    }()
    
    private let toggleView = LibraryToggleView()
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = .systemBackground
        scrollView.delegate = self
        toggleView.delegate = self
        
        view.addSubview(self.scrollView)
        view.addSubview(self.toggleView)
        
        scrollView.contentSize = CGSize(width: view.width * 2, height: scrollView.height)
        addChildren()
        updateBarButtons()
    }
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        scrollView.frame = CGRect(x: 0,
                                  y: view.safeAreaInsets.top + 55,
                                  width: view.width,
                                  height: view.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom - 55)
        
        
        toggleView.frame = CGRect(x: 0,
                                  y: view.safeAreaInsets.top,
                                  width: 200,
                                  height: 55)
        
    }
    
    private func addChildren()
    {
        addChild(playlistsVC)
        scrollView.addSubview(playlistsVC.view)
        playlistsVC.view.frame = CGRect(x: 0,
                                        y: 0,
                                        width: scrollView.width,
                                        height: scrollView.height)
        playlistsVC.didMove(toParent: self)
        
        addChild(albumsVC)
        scrollView.addSubview(albumsVC.view)
        albumsVC.view.frame = CGRect(x: view.width,
                                        y: 0,
                                        width: scrollView.width,
                                        height: scrollView.height)
        playlistsVC.didMove(toParent: self)
    }
    
    private func updateBarButtons()
    {
        switch toggleView.state
        {
        case .playlist:
            let barButtonItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                                 target: self,
                                                                 action: #selector(didTapAddButton))
            navigationItem.rightBarButtonItem = barButtonItem
        case .album:
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    @objc private func didTapAddButton()
    {
        self.playlistsVC.showCreatePlaylistAlert()
    }
}

extension LibraryViewController: UIScrollViewDelegate
{
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        if scrollView.contentOffset.x >= (view.width - 100)
        {
            self.toggleView.update(for: .album)
        }
        else
        {
            self.toggleView.update(for: .playlist)
        }
    }
}

extension LibraryViewController: LibraryToggleViewDelegate
{
    func toggleViewDidTapPlaylistButton(_ toggleView: LibraryToggleView)
    {
        self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        self.updateBarButtons()
    }
    
    func toggleViewDidTapAlbumsButton(_ toggleView: LibraryToggleView)
    {
        self.scrollView.setContentOffset(CGPoint(x: view.width, y: 0), animated: true)
        self.updateBarButtons()
    }
}
