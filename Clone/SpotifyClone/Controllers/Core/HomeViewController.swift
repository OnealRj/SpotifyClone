//
//  ViewController.swift
//  SpotifyClone
//
//  Created by Rj O'Neal on 5/14/23.
//

import UIKit

enum BrowseSectionType
{
    case newReleases(viewModels: [NewReleasesCellViewModel]) //1
    case featuredPlaylists(viewModels: [FeaturedPlaylistCellViewModel]) //2
    case recommendedTracks(viewModels: [RecommendedTrackCellViewModel]) //3
    
    var title: String
    {
        switch self
        {
            case .newReleases:
                return "New Releases Albums"
            case .featuredPlaylists:
                return "Featured Playlists"
            case .recommendedTracks:
                return "Recommended Tracks"
        }
    }
}

class HomeViewController: UIViewController
{
    private var newAlbums: [Album]?
    private var playlists: [PlaylistItem]?
    private var tracks:[AudioTrack]?
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewCompositionalLayout { sectionIndex, _ -> NSCollectionLayoutSection? in
        return self.createSectionLayout(index: sectionIndex)
    })
    
    private let spinner: UIActivityIndicatorView =
    {
        let spinner = UIActivityIndicatorView()
        spinner.tintColor = .label
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    private var sections = [BrowseSectionType]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = "Home"
        self.view.backgroundColor = .systemBackground
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .done, target: self, action: #selector(didTapSettings))
        self.configureCollectionView()
        self.view.addSubview(self.spinner)
        self.fetchData()
        self.addLongTapGesture()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.collectionView.frame = view.bounds
    }
    
    private func configureCollectionView()
    {
        self.view.addSubview(self.collectionView)
        
        self.collectionView.register(NewReleaseCollectionViewCell.self, forCellWithReuseIdentifier: NewReleaseCollectionViewCell.identifier)
        self.collectionView.register(FeaturedPlaylistCollectionViewCell.self, forCellWithReuseIdentifier: FeaturedPlaylistCollectionViewCell.identifier)
        self.collectionView.register(RecommendedTrackCollectionViewCell.self, forCellWithReuseIdentifier: RecommendedTrackCollectionViewCell.identifier)
        self.collectionView.register(TitleHeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TitleHeaderCollectionReusableView.identifier)
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.backgroundColor = .systemBackground
    }
    
    private func addLongTapGesture()
    {
        let gesture = UILongPressGestureRecognizer(target: self,
                                             action: #selector(didLongPress(_:)))
        collectionView.isUserInteractionEnabled = true
        view.addGestureRecognizer(gesture)
    }
    
    @objc func didLongPress(_ gesture: UILongPressGestureRecognizer)
    {
        guard gesture.state == .began else {
            return
        }
        
        let touchPoint = gesture.location(in: collectionView)
        guard let indexPath = collectionView.indexPathForItem(at: touchPoint),
              indexPath.section == 2,
              let model = tracks?[indexPath.row] as? AudioTrack else { return }
        let actionSheet = UIAlertController(title: model.name,
                                            message: "Would you like to add this to a playlist?",
                                            preferredStyle: .actionSheet)
        
        
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                           handler: nil))
        
        actionSheet.addAction(UIAlertAction(title: "Add to Playlist",
                                            style: .default) { [weak self] _ in
            DispatchQueue.main.async {
                let vc = LibraryPlaylistsViewController()
                vc.selectionHandler = { playlist in
                    APICaller.shared.addTrackToPlaylist(track: model, playlist: playlist){ success in
                        switch success
                        {
                        case true:
                            print("Added to playlist succes: \(success)")
                        case false:
                            print("There appeared to be an error")
                        }
                    }
                }
                vc.title = "Select Playlist?"
                self?.present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
            }
        })
        present(actionSheet, animated: true)
    }

    
    
    private func fetchData()
    {
        let group = DispatchGroup()
        group.enter()
        group.enter()
        group.enter()
        
        var newReleases: NewReleasesRespose?
        var featuredPlaylists: FeaturedPlaylistResponse?
        var recommendations: RecommendationsReponse?
        
        //New Releases
        APICaller.shared.getNewReleases
        {
            result in
            defer {
                group.leave()
            }
            switch result{
                case .success(let model):
                    newReleases = model
                case .failure(let error):
                    print(error.localizedDescription)
            }
        }
        
        // Featured playlists
        APICaller.shared.getFeaturedPlaylists { result in
            defer {
                group.leave()
            }
            switch(result)
            {
            case .success(let model):
                featuredPlaylists = model
            case .failure(let error):
                print(error.localizedDescription)
            }
            
        }
        
        // Recommended Tracks
        APICaller.shared.getUserRecommendedGenres { result in
            switch result
            {
                case .success(let model):
                    var seeds = Set<String>()
                    let genres = model.genres
                    while seeds.count < 5
                    {
                        if let newGenre = genres.randomElement()
                        {
                            seeds.insert(newGenre)
                        }
                    }
                APICaller.shared.getUserRecommendations(genres: seeds) { result in
                        defer {
                            group.leave()
                        }
                        switch result
                        {
                            case .success(let model):
                                recommendations = model
                            case .failure(let error):
                            print(error.localizedDescription)
                        }
                    }
                case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
        group.notify(queue: .main)
        {
            guard let newAlbums = newReleases?.albums.items, let playlists = featuredPlaylists?.playlists.items, let tracks = recommendations?.tracks else
            {
                fatalError("Models are nil")
                return
            }
            print("configuring ViewModels")
            self.configureModels(newAlbums: newAlbums, tracks: tracks, playlist: playlists)
        }
    }
    
    private func configureModels(newAlbums: [Album], tracks:[AudioTrack], playlist:[PlaylistItem])
    {
        self.newAlbums = newAlbums
        self.tracks = tracks
        self.playlists = playlist
        
        sections.append(.newReleases(viewModels: newAlbums.compactMap({
            return NewReleasesCellViewModel(name: $0.name, artworkURL: URL(string: $0.images.first?.url ?? ""), numberOfTracks: $0.total_tracks, artistName: $0.artists.first?.name ?? "-")
        })))
        
        sections.append(.featuredPlaylists(viewModels: playlist.compactMap({
            return FeaturedPlaylistCellViewModel(name: $0.name, artworkURL: URL(string: $0.images?.first?.url ?? ""), creatorName: $0.owner.display_name)
        })))
        
        sections.append (.recommendedTracks(viewModels: tracks.compactMap({
            return RecommendedTrackCellViewModel(name: $0.name, artistName: $0.artists.first?.name ?? "", artworkURL: URL(string: $0.album?.images.first?.url ?? ""))
        })))
            
        collectionView.reloadData()
    }
    
    @objc func didTapSettings()
    {
        let vc = SettingsViewController()
        vc.title = "Settings"
        vc.navigationItem.largeTitleDisplayMode = .never
        self.navigationController?.pushViewController(vc, animated: true)
    }
}


extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        let type  = sections[section]
        switch type
        {
            case .newReleases(let viewModels):
                return viewModels.count
            case .featuredPlaylists(let viewModels):
                return viewModels.count
            case .recommendedTracks(let viewModels):
                return viewModels.count
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        HapticsManager.shared.vibrateForSelection()
        let type = sections[indexPath.section]
        switch type
        {
            case .newReleases:
            guard let album = newAlbums?[indexPath.row] else{ return}
                let vc = AlbumViewController(album: album)
                vc.navigationItem.largeTitleDisplayMode = .never
                self.navigationController?.pushViewController(vc, animated: true)
                break
            case .featuredPlaylists:
                guard let playlist = playlists?[indexPath.row] else {return}
                let vc = PlaylistViewController(playlist: playlist)
                vc.navigationItem.largeTitleDisplayMode = .never
                self.navigationController?.pushViewController(vc, animated: true)
                break
            case .recommendedTracks:
                guard let track = tracks?[indexPath.row] else {return}
                PlaybackPresenter.shared.startPlayback(from: self, track: track)
                break
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        self.collectionView.deselectItem(at: indexPath, animated: true)
        let type = sections[indexPath.section]
        switch type
        {
            case .newReleases(let viewModels):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewReleaseCollectionViewCell.identifier, for: indexPath) as? NewReleaseCollectionViewCell else{return UICollectionViewCell()}
                let viewModel = viewModels[indexPath.row]
                cell.configure(with: viewModel)
                return cell
            
            case .featuredPlaylists(let viewModels):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeaturedPlaylistCollectionViewCell.identifier, for: indexPath) as? FeaturedPlaylistCollectionViewCell else{return UICollectionViewCell()}
                let viewModel = viewModels[indexPath.row]
                cell.configure(with: viewModel)
                return cell
            
            
            case .recommendedTracks(let viewModels):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecommendedTrackCollectionViewCell.identifier, for: indexPath) as? RecommendedTrackCollectionViewCell else{return UICollectionViewCell()}
                let viewModel = viewModels[indexPath.row]
                cell.configure(with: viewModel)
                return cell
            }
    }
    
    func createSectionLayout(index: Int) -> NSCollectionLayoutSection
    {
        let supplementaryViews = [
            NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                   heightDimension: .absolute(50)),
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top)
        
        ]
        
        switch(index)
        {
            case 0:
                // Item
                let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
                item.contentInsets = NSDirectionalEdgeInsets(top: 2.0, leading: 2.0, bottom: 2.0, trailing: 2.0)
                
                // vertical group inside of a horizontal group
                let verticalGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(360)), subitem: item, count: 3)
                
                // Group
                let horizontalGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .absolute(360)), subitem: verticalGroup, count: 1)
                // Section
                let section = NSCollectionLayoutSection(group: horizontalGroup)
                section.orthogonalScrollingBehavior = .continuous
                section.boundarySupplementaryItems = supplementaryViews
                return section
            case 1:
                // Item
                let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(200), heightDimension: .absolute(200)))
                
                item.contentInsets = NSDirectionalEdgeInsets(top: 2.0, leading: 2.0, bottom: 2.0, trailing: 2.0)
                
                // vertical group inside of a horizontal group
                let verticalGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(200), heightDimension: .absolute(400)), subitem: item, count: 2)
                
                // Group
                let horizontalGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(200), heightDimension: .absolute(400)), subitem: verticalGroup, count: 1)
                // Section
                let section = NSCollectionLayoutSection(group: horizontalGroup)
                section.orthogonalScrollingBehavior = .continuous
                section.boundarySupplementaryItems = supplementaryViews
                return section
            case 2:
                // Item
                let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
                
                item.contentInsets = NSDirectionalEdgeInsets(top: 2.0, leading: 2.0, bottom: 2.0, trailing: 2.0)
                
                // vertical group inside of a horizontal group
                // Group
                let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(80)), subitem: item, count: 1)
                
                // Section
                let section = NSCollectionLayoutSection(group: group)
                section.boundarySupplementaryItems = supplementaryViews
                return section
            default:
                // Item
                let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
                
                item.contentInsets = NSDirectionalEdgeInsets(top: 2.0, leading: 2.0, bottom: 2.0, trailing: 2.0)
                
                // vertical group inside of a horizontal group
                let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(360)), subitem: item, count: 1)
                
                // Section
                let section = NSCollectionLayoutSection(group: group)
                section.boundarySupplementaryItems = supplementaryViews
                return section
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView
        {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TitleHeaderCollectionReusableView.identifier,for: indexPath) as? TitleHeaderCollectionReusableView, kind == UICollectionView.elementKindSectionHeader else{ return UICollectionReusableView()}
        let model = sections[indexPath.section]
        header.configure(with: model.title)
        return header
    }
}

