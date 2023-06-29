//
//  SettingsViewController.swift
//  SpotifyClone
//
//  Created by Rj O'Neal on 5/14/23.
//

import UIKit

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
  
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    private var sections = [Section]()

    override func viewDidLoad()
    {
        super.viewDidLoad()
        title = "Settings"
        self.view.backgroundColor = .systemBackground
        self.view.addSubview(self.tableView)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.configureModels()
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        self.tableView.frame = view.bounds
    }

    // MARK: Building tableView
    private func configureModels()
    {
        self.sections.append(Section(title: "Profile", options:
                                        [Option(title: "View Your Profile", handler: { [weak self] in
                                        DispatchQueue.main.async {self?.viewYourProfile()}
                                        })]))
        self.sections.append(Section(title: "Account", options:
                                        [Option(title: "Sign Out", handler: { [weak self] in
            DispatchQueue.main.async {self?.signOutTapped()}
                                        })]))
    }
                                         
    func viewYourProfile()
    {
        let vc = ProfileViewController()
        vc.title = "Profile"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    private func signOutTapped()
    {
        let alert = UIAlertController(title: "Sign Out",
                                      message: "Are you sure?",
                                      preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel,
                                         handler: nil)
        let signOutAction = UIAlertAction(title: "Sign Out", style: .destructive) { _ in
            AuthManager.shared.signOut {[weak self] signedOut in
                switch signedOut
                {
                case true:
                    DispatchQueue.main.async
                    {
                        let navVC = UINavigationController(rootViewController: WelcomeViewController())
                        navVC.navigationBar.prefersLargeTitles = true
                        navVC.viewControllers.first?.navigationItem.largeTitleDisplayMode = .always
                        navVC.modalPresentationStyle = .fullScreen
                        self?.present(navVC, animated: true, completion: nil)
                        self?.navigationController?.popViewController(animated: false)
                    }
                case false:
                    print("failed to sign out")
                }
            }
        }
        alert.addAction(cancelAction)
        alert.addAction(signOutAction)
        present(alert,
                animated: true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: -TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.sections[section].options.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = sections[indexPath.section].options[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as UITableViewCell
        cell.textLabel?.text = model.title
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = sections[indexPath.section].options[indexPath.row]
        model.handler()
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let model = sections[section]
        return model.title
    }

}
