//
//  PlaylistViewController.swift
//  SpotifyClone
//
//  Created by Rj O'Neal on 5/14/23.
//

import UIKit

class PlaylistViewController: UIViewController
{
    private var viewModels: [RecommendedTrackCellViewModel]
    private var playlist:PlaylistItem
    private var tracks: [AudioTrack]
    
    public var isOwner: Bool = false
    
    var initialCenter: CGPoint?
    
    init(playlist: PlaylistItem)
    {
        viewModels = [RecommendedTrackCellViewModel]()
        tracks = [AudioTrack]()
        isOwner = false
        self.playlist = playlist
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder)
    {
        fatalError()
    }
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { (_,_) -> NSCollectionLayoutSection? in
        return self.createSectionLayout()
    }))
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        
        view.addSubview(collectionView)
        collectionView.register(RecommendedTrackCollectionViewCell.self, forCellWithReuseIdentifier: RecommendedTrackCollectionViewCell.identifier)
        collectionView.register(PlaylistHeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: PlaylistHeaderCollectionReusableView.identifer)
        
        title = playlist.name
        view.backgroundColor = .systemBackground
        self.getPlaylistDetail()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action,
                                                            target: self,
                                                            action: #selector(didTapShare))
    }
    
    @objc private func didTapShare()
    {
        guard let url = URL(string: playlist.external_urls["spotify"] as? String ?? "") else {
            return
        }
        let vc = UIActivityViewController(activityItems: [url], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.collectionView.frame = view.bounds
        
        
    }
    
    private func getPlaylistDetail()
    {
        APICaller.shared.getPlaylistDetails(for: self.playlist) { [weak self] result in
            DispatchQueue.main.async {
                switch result
                {
                    case .success(let playlist):
                    self?.tracks = playlist.tracks.items.compactMap({ $0.track})
                    self?.viewModels = playlist.tracks.items.compactMap({
                        return RecommendedTrackCellViewModel(name: $0.track.name,
                                                             artistName: $0.track.artists.first?.name ?? "-",
                                                             artworkURL: URL(string: $0.track.album?.images.first?.url ?? ""))
                    })
                    self?.collectionView.reloadData()
                    case .failure(let error):
                        print(error.localizedDescription)
                }
            }
        }
    }

}

extension PlaylistViewController: UICollectionViewDelegate, UICollectionViewDataSource
{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell  {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecommendedTrackCollectionViewCell.identifier, for: indexPath) as? RecommendedTrackCollectionViewCell else { return UICollectionViewCell()}
        let viewModel = self.viewModels[indexPath.row]
        cell.configure(with: viewModel)
        if self.isOwner
        {
            cell.delegate = self
            cell.addGesture()
        }
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
            name: playlist.name,
            owner: playlist.owner.display_name,
            description: playlist.description,
            artworkURL: URL(string: playlist.images?.first?.url ?? "")
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
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                   heightDimension: .fractionalWidth(1)),
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top)
        ]
        return section
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        collectionView.deselectItem(at: indexPath, animated: true)
        // Play Song
        let track = self.tracks[indexPath.row]
        PlaybackPresenter.shared.startPlayback(from: self, track: track)
    }
}

extension PlaylistViewController: RecommendedTrackCollectionViewCellDelegate
{
    func recommendedTrackCollectionViewCellDidSwipeToDelete(_ cell: RecommendedTrackCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return
        }
        let track = self.tracks[indexPath.row]
        APICaller.shared.removeTrackFromPlaylist(track: track,
                                                 playlist: playlist) { [weak self] result in
            guard let strongSelf = self else
            {
                return
            }
            DispatchQueue.main.async {
                switch result
                {
                case true:
                    print("Removed!")
                    strongSelf.tracks.remove(at: indexPath.row)
                    strongSelf.viewModels.remove(at: indexPath.row)
                    strongSelf.collectionView.deleteItems(at: [indexPath])
                    strongSelf.collectionView.reloadData()
                case false:
                    print("DID NOT DELETE")
                }
            }
        }
    }
}

extension PlaylistViewController: PlaylistHeaderCollectionReusableViewDelegate
{
    func PlaylistHeaderCollectionReusableViewDidTapPlayAll(_ header: PlaylistHeaderCollectionReusableView) {
        // start play list play in queue
        PlaybackPresenter.shared.startPlayback(from: self, tracks: self.tracks)
    }
}
