//
//  AlbumViewController.swift
//  SpotifyClone
//
//  Created by Rj O'Neal on 5/22/23.
//

import UIKit

class AlbumViewController: UIViewController
{
    private var viewModels: [AlbumCollectionViewCellViewModel]
    
    private var album:Album
    private var tracks: [AudioTrack]
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { (_,_) -> NSCollectionLayoutSection? in
        return self.createSectionLayout()
    }))
    
    init(album: Album)
    {
        self.album = album
        self.tracks = [AudioTrack]()
        self.viewModels = [AlbumCollectionViewCellViewModel]()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        title = album.name
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        
        collectionView.register(AlbumTrackCollectionViewCell.self, forCellWithReuseIdentifier: AlbumTrackCollectionViewCell.identifier)
        collectionView.register(PlaylistHeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: PlaylistHeaderCollectionReusableView.identifer)
        
        
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        title = album.name
        view.backgroundColor = .systemBackground
        self.getAlbumDetail()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(didTapActions))
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        self.collectionView.frame = view.bounds
    }
    
    private func getAlbumDetail()
    {
        APICaller.shared.getAlbumDetails(for: self.album) { [weak self] result in
            DispatchQueue.main.async {
                switch result
                {
                case .success(let album):
                    self?.tracks = album.tracks.items
                    self?.viewModels = album.tracks.items.compactMap({
                        return AlbumCollectionViewCellViewModel(name: $0.name,
                                                             artistName: $0.artists.first?.name ?? "-",
                                                             artworkURL: URL(string: $0.album?.images.first?.url ?? ""))
                    })
                    self?.collectionView.reloadData()
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    @objc private func didTapActions()
    {
        let actionSheet = UIAlertController(title: album.name, message: "Actions", preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        let save = UIAlertAction(title: "Save Album", style: .default) { _ in
            APICaller.shared.addAlbumToSavedLibrary(album: self.album) { [weak self] succ in
                switch succ
                {
                case true:
                    HapticsManager.shared.vibrate(for: .success)
                    NotificationCenter.default.post(name: .albumSavedNotification, object: nil)
                case false:
                    HapticsManager.shared.vibrate(for: .error)
                    print("did not save album")
                }
            }
        }
        actionSheet.addAction(cancel)
        actionSheet.addAction(save)
        present(actionSheet, animated: true)
    }
}

extension AlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource
{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return self.viewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AlbumTrackCollectionViewCell.identifier, for: indexPath) as? AlbumTrackCollectionViewCell else { return UICollectionViewCell()}
        let viewModel = self.viewModels[indexPath.row]
        cell.configure(with: viewModel)
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                           withReuseIdentifier: PlaylistHeaderCollectionReusableView.identifer,
                                                                           for: indexPath) as? PlaylistHeaderCollectionReusableView, kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        // header.configure(with: headerViewModel)
        let headerViewModel = PlaylistHeaderViewViewModel(
            name: album.name,
            owner: album.artists.first?.name,
            description: "Release Date: \(String.formattedDate(string: album.release_date))",
            artworkURL: URL(string: album.images.first?.url ?? "")
        )
        header.configure(with: headerViewModel)
        header.delegate = self
        return header
    }
    
    func createSectionLayout() -> NSCollectionLayoutSection
    {
        // Item
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
        
        item.contentInsets = NSDirectionalEdgeInsets(top: 1.0, leading: 2.0, bottom: 1.0, trailing: 2.0)
        
        // vertical group inside of a horizontal group
        
        // Group
        let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(60)), subitem: item, count: 1)
        
        // Section
        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [
            NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1)),
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top)
        ]
        return section
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.collectionView.deselectItem(at: indexPath, animated: true)
        // Play Song
        var track = self.tracks[indexPath.row]
        track.album = self.album
        PlaybackPresenter.shared.startPlayback(from: self, track: track)
    }
    
}

extension AlbumViewController: PlaylistHeaderCollectionReusableViewDelegate
{
    func PlaylistHeaderCollectionReusableViewDidTapPlayAll(_ header: PlaylistHeaderCollectionReusableView) {
        let tracksWithAlbum: [AudioTrack] = tracks.compactMap({
            var track = $0
            track.album = self.album
            return track
        })
        PlaybackPresenter.shared.startPlayback(from: self, tracks: tracksWithAlbum)
    }
}







