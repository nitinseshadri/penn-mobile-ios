//
//  DiningViewController.swift
//  PennMobile
//
//  Created by Josh Doman on 3/12/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

class DiningViewController: GenericTableViewController {
    
    fileprivate var viewModel = DiningViewModel()
    
    fileprivate let venueToPreload: DiningVenueName = .commons
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        tableView.dataSource = self
        
        self.screenName = "Dining"
        
        viewModel.delegate = self
        viewModel.registerHeadersAndCells(for: tableView)
        
        tableView.dataSource = viewModel
        tableView.delegate = viewModel
        
        prepareRefreshControl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchDiningHours()
        self.tabBarController?.title = "Dining"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        refreshControl?.endRefreshing()
    }
}

//Mark: Networking to retrieve today's times
extension DiningViewController {
    fileprivate func fetchDiningHours() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        DiningAPI.instance.fetchDiningHours { (success, error) in
            DispatchQueue.main.async {
                if success {
                    DiningHoursData.shared.clearHours()
                    
                    let errorBar = UIView()
                    self.navigationController!.view.addSubview(errorBar)
                    var heightConstraint: NSLayoutConstraint!
                    heightConstraint = errorBar.heightAnchor.constraint(equalToConstant: 0)
                    heightConstraint.isActive = true
                    errorBar.backgroundColor = .redingTerminal
                    errorBar.translatesAutoresizingMaskIntoConstraints = false
//                    errorBar.heightAnchor.constraint(equalToConstant: 0).isActive = true
                    errorBar.topAnchor.constraint(equalTo: self.navigationController!.navigationBar.bottomAnchor).isActive = true
                    errorBar.leadingAnchor.constraint(equalTo: self.navigationController!.view.leadingAnchor).isActive = true
                    errorBar.trailingAnchor.constraint(equalTo: self.navigationController!.view.trailingAnchor).isActive = true
                    errorBar.layoutIfNeeded()
                    heightConstraint.constant = 50
                    
                    UIView.animate(withDuration: 5, delay: 0.5, options: [], animations: {
                        self.view.layoutIfNeeded()
                    })
                    
                }
                self.tableView.reloadData()
                
                self.refreshControl?.endRefreshing()
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
}

// MARK: - UIRefreshControl
extension DiningViewController {
    fileprivate func prepareRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(handleRefresh(_:)), for: .valueChanged)
    }
    
    @objc fileprivate func handleRefresh(_ sender: Any) {
        fetchDiningHours()
    }
}

// MARK: - DiningViewModelDelegate
extension DiningViewController: DiningViewModelDelegate {
    func handleSelection(for venue: DiningVenue) {
        //let ddc = DiningDetailViewController()
        //ddc.venue = venue
        //navigationController?.pushViewController(ddc, animated: true)
        
        UserDBManager.shared.saveDiningPreference(for: venue)
        DatabaseManager.shared.trackEvent(vcName: "Dining", event: venue.name.rawValue)
        
        if let urlString = DiningDetailModel.getUrl(for: venue.name), let url = URL(string: urlString) {
//            UIApplication.shared.open(url, options: [:])
            let vc = UIViewController()
            let webView = GenericWebview(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
            webView.loadRequest(URLRequest(url: url))
            vc.view.addSubview(webView)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

