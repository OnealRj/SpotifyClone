//
//  ProfileViewController.swift
//  SpotifyClone
//
//  Created by Rj O'Neal on 5/14/23.
//
import SDWebImage
import UIKit

class ProfileViewController: UIViewController, UITableViewDataSource,UITableViewDelegate {
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.isHidden = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    private var models = [String]()

    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.fetchProfile()
        self.view.addSubview(self.tableView)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        title = "Profile"
        view.backgroundColor = .systemBackground
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    
    private func fetchProfile()
    {
        APICaller.shared.getCurrentUserProfile{[weak self] result in
            DispatchQueue.main.sync {
                switch result{
                case .success(let model):
                    self?.updateUI(with: model)
                case .failure(let error):
                    self?.failedToGetProfile()
                }
            }
        }
    }
    
    private func updateUI(with model: UserProfile)
    {
        self.tableView.isHidden = false
        //configure table model
        self.tableView.reloadData()
        self.models.append("Full Name: \(model.display_name)")
        self.models.append("Email Address: \(model.email)")
        self.models.append("User ID: \(model.id)")
        self.models.append("Plan: \(model.product)")
        self.updateTableHeader(with: model.images.first?.url)
        self.tableView.reloadData()
    }
    private func updateTableHeader(with string:String?)
    {
        guard let urlString = string, let url = URL(string: urlString) else
        {
            return
        }
        
        let headerView = UIView(frame: CGRect(x:0, y:0, width: view.width, height: view.width / 1.5))
        let imageSize: CGFloat = headerView.height/2
        let imageView = UIImageView(frame: CGRect(x:0, y:0, width: imageSize, height: imageSize))
        
        headerView.addSubview(imageView)
        imageView.center = headerView.center
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageSize/2
        imageView.sd_setImage(with: url, completed: nil)
        tableView.tableHeaderView = headerView
    }
    private func failedToGetProfile()
    {
        let label = UILabel(frame: .zero)
        label.text = "Failed to load profile."
        label.sizeToFit()
        label.textColor = .secondaryLabel
        view.addSubview(label)
        label.center = view.center
    }
    
    // MARK: TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currString = self.models[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? UITableViewCell
        cell?.textLabel?.text = currString
        cell?.selectionStyle = .none
        return cell ?? UITableViewCell()
    }

}
