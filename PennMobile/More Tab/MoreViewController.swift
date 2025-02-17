//
//  MoreViewController.swift
//  PennMobile
//
//  Created by Zhilei Zheng on 3/17/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import UIKit

class MoreViewController: GenericTableViewController, ShowsAlert {

    var account: Account?

    fileprivate var barButton: UIBarButtonItem!

    private var shouldShowProfile: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        if shouldShowProfile {
            account = Account.getAccount()
        }
        setUpTableView()
        self.tableView.isHidden = true

        barButton = UIBarButtonItem(title: Account.isLoggedIn ? "Logout" : "Login", style: .done, target: self, action: #selector(handleLoginLogout(_:)))
        barButton.tintColor = UIColor.navigation
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if shouldShowProfile {
            let account = Account.getAccount()
            if self.account != account {
                self.account = account
            }
        }
        tableView.reloadData()
    }

    override func setupNavBar() {
        self.tabBarController?.title = "More"
        barButton = UIBarButtonItem(title: Account.isLoggedIn ? "Logout" : "Login", style: .done, target: self, action: #selector(handleLoginLogout(_:)))
        barButton.tintColor = UIColor.navigation
        tabBarController?.navigationItem.leftBarButtonItem = nil
        tabBarController?.navigationItem.rightBarButtonItem = barButton
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let topSpace: CGFloat?
        topSpace = self.view.safeAreaInsets.top
        if let topSpace = topSpace, topSpace > 0 {
            self.tableView.isHidden = false
        }
    }

    func setUpTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.uiGroupedBackground
        tableView.separatorStyle = .singleLine
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 50
        tableView.register(MoreCell.self, forCellReuseIdentifier: "more")
        tableView.register(MoreCell.self, forCellReuseIdentifier: "more-with-icon")
        tableView.tableFooterView = UIView()
    }

    fileprivate struct PennLink {
        let title: String
        let url: String
    }

    fileprivate let pennLinks: [PennLink] = [
        PennLink(title: "Penn Labs", url: "https://pennlabs.org"),
        PennLink(title: "Penn Homepage", url: "https://upenn.edu"),
        PennLink(title: "CampusExpress", url: "https://prod.campusexpress.upenn.edu"),
        PennLink(title: "Canvas", url: "https://canvas.upenn.edu"),
        PennLink(title: "PennInTouch", url: "https://pennintouch.apps.upenn.edu"),
        PennLink(title: "PennPortal", url: "https://portal.apps.upenn.edu/penn_portal"),
        PennLink(title: "Share Your Feedback", url: "https://airtable.com/shrS98E3rj5Nw1wy6")]

}

extension MoreViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Notification and privacy tabs aren't shown for users that aren't logged in
        let rows = [Account.isLoggedIn ? 4 : 3, ControllerModel.shared.moreOrder.count, pennLinks.count]
        return rows[section]
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = HeaderViewCell()
        let titles = ["ACCOUNT", "FEATURES", "LINKS"]
        headerView.setUpView(title: titles[section])
        return headerView
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "more") as? MoreCell {
                    cell.setUpView(with: "View your profile")
                    cell.backgroundColor = .uiGroupedBackgroundSecondary
                    cell.accessoryType = .disclosureIndicator
                    return cell
                }
            } else if indexPath.row == 1 {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "more") as? MoreCell {
                    cell.setUpView(with: "PAC Code")
                    cell.backgroundColor = .uiGroupedBackgroundSecondary
                    cell.accessoryType = .disclosureIndicator
                    return cell
                }
            } else if indexPath.row <= 3 {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "more") as? MoreCell {
                    cell.setUpView(with: indexPath.row == 2 ? "Notifications" : "Privacy")
                    cell.backgroundColor = .uiGroupedBackgroundSecondary
                    cell.accessoryType = .disclosureIndicator
                    return cell
                }
            }
        } else if indexPath.section == 1 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "more-with-icon") as? MoreCell {
                cell.setUpView(with: ControllerModel.shared.moreOrder[indexPath.row], icon: ControllerModel.shared.moreIcons[indexPath.row])
                cell.backgroundColor = .uiGroupedBackgroundSecondary
                cell.accessoryType = .disclosureIndicator
                return cell
            }
        } else if indexPath.section == 2 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "more") as? MoreCell {
                cell.backgroundColor = .uiGroupedBackgroundSecondary
                cell.setUpView(with: pennLinks[indexPath.row].title)
                cell.accessoryType = .disclosureIndicator
                return cell
            }
        }
        return UITableViewCell()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let targetController = ProfilePageViewController()
                navigationController?.pushViewController(targetController, animated: true)
            } else if indexPath.row == 1 {
                let targetController = ControllerModel.shared.viewController(for: .pacCode)
                navigationController?.pushViewController(targetController, animated: true)
            } else if indexPath.row <= 3 {
                let targetController = ControllerModel.shared.viewController(for: indexPath.row == 2 ? .notifications : .privacy)
                navigationController?.pushViewController(targetController, animated: true)
            }
        } else if indexPath.section == 1 {
            let targetController = ControllerModel.shared.viewController(for: ControllerModel.shared.moreOrder[indexPath.row])
            navigationController?.pushViewController(targetController, animated: true)
        } else if indexPath.section == 2 {
            if let url = URL(string: pennLinks[indexPath.row].url) {
                UIApplication.shared.open(url, options: [:])
            }
        }
    }
}

// MARK: - Login/Logout
extension MoreViewController {
    @objc fileprivate func handleLoginLogout(_ sender: Any) {
        if Account.isLoggedIn {
            let alertController = UIAlertController(title: "Are you sure?", message: "Please confirm that you wish to logout.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            alertController.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { (_) in
                DispatchQueue.main.async {
                    AppDelegate.shared.rootViewController.clearAccountData()
                    AppDelegate.shared.rootViewController.switchToLogout()
                }
            }))
            present(alertController, animated: true, completion: nil)
        } else {
            let llc = LabsLoginController { (success) in
                DispatchQueue.main.async {
                    self.loginCompletion(success)
                }
            }
            let nvc = UINavigationController(rootViewController: llc)
            present(nvc, animated: true, completion: nil)
        }
    }

    func loginCompletion(_ successful: Bool) {
        if successful {
            if shouldShowProfile {
                self.account = Account.getAccount()
            }

            tableView.reloadData()
            tabBarController?.navigationItem.rightBarButtonItem?.title = "Logout"

            // Clear cache so that home title updates with new first name
            guard let homeVC = ControllerModel.shared.viewController(for: .home) as? HomeViewController else {
                return
            }
            homeVC.clearCache()
        } else {
            showAlert(withMsg: "Something went wrong. Please try again.", title: "Uh oh!", completion: nil)
        }
    }
}
