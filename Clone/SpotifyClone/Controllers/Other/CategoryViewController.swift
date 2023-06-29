//
//  CategoryViewController.swift
//  SpotifyClone
//
//  Created by Rj O'Neal on 5/29/23.
//

import UIKit

class CategoryViewController: UIViewController
{
    let category: CategoryReponseItem
    private var playlists: [PlaylistItem]
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: {(_,_) -> NSCollectionLayoutSection? in
        return self.configureLayout()
    }))
    
    // Mark: - Init

    init(category: CategoryReponseItem)
    {
        self.category = category
        self.playlists = [PlaylistItem]()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // Mark: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = category.name
        view.addSubview(self.collectionView)
        collectionView.backgroundColor = .systemGray2
        collectionView.delegate = self
        collectionView.dataSource = self
        self.collectionView.register(FeaturedPlaylistCollectionViewCell.self, forCellWithReuseIdentifier: FeaturedPlaylistCollectionViewCell.identifier)
        self.getCategoryInformation()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    private func getCategoryInformation()
    {
        APICaller.shared.getCategoryPlaylist(with: self.category){[weak self] result in
            DispatchQueue.main.async
            {
                switch result
                {
                case .success(let playlists):
                    self?.playlists = playlists
                    self?.collectionView.reloadData()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
}

extension CategoryViewController: UICollectionViewDelegate, UICollectionViewDataSource
{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.playlists.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeaturedPlaylistCollectionViewCell.identifier , for: indexPath) as? FeaturedPlaylistCollectionViewCell else { return UICollectionViewCell()}
        cell.backgroundColor = .systemRed
        let playlist = self.playlists[indexPath.row]
        let viewModel = FeaturedPlaylistCellViewModel(name: playlist.name,
                                                      artworkURL: URL(string: playlist.images?.first?.url ?? ""),
                                                      creatorName: playlist.owner.display_name)
        cell.configure(with: viewModel)
        return cell
    }
    private func configureLayout() -> NSCollectionLayoutSection
    {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                                             heightDimension: .fractionalHeight(1)))
        
        item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                                                          heightDimension: .absolute(250)),
                                                       subitem: item, count: 2)
        group.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
        let section = NSCollectionLayoutSection(group: group)
        return section
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let playlist = self.playlists[indexPath.row]
        let vc = PlaylistViewController(playlist: playlist)
        vc.navigationItem.largeTitleDisplayMode = .never
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
