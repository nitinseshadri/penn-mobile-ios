//
//  GSROverhallController.swift
//  PennMobile
//
//  Created by Zhilei Zheng on 2/2/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import UIKit

class GSROverhallController: GenericViewController {
    
    // MARK: UI Elements
    fileprivate var tableView: UITableView!
    fileprivate var rangeSlider: GSRRangeSlider!
    fileprivate var pickerView: UIPickerView!
    fileprivate var emptyView: EmptyView!
    fileprivate var barButton: UIBarButtonItem!
    
    var barButtonTitle: String {
        get {
            switch viewModel.state {
            case .loggedIn:
                return "Logout"
            case .loggedOut:
                return "Login"
            case .readyToSubmit:
                return "Submit"
            }
        }
    }
    
    fileprivate var viewModel: GSRViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Study Room Booking"
        
        prepareViewModel()
        prepareUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        rangeSlider?.reload()
        revealViewController().panGestureRecognizer().delegate = self
        fetchData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        revealViewController().panGestureRecognizer().delegate = nil
    }
}

// MARK: - Setup UI
extension GSROverhallController {
    fileprivate func prepareUI() {
        preparePickerView()
        prepareRangeSlider()
        prepareTableView()
        prepareEmptyView()
        prepareBarButton()
    }
    
    private func preparePickerView() {
        pickerView = UIPickerView(frame: .zero)
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        pickerView.delegate = viewModel
        pickerView.dataSource = viewModel
        
        view.addSubview(pickerView)
        pickerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 60).isActive = true
        pickerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    private func prepareRangeSlider() {
        rangeSlider = GSRRangeSlider()
        rangeSlider.delegate = viewModel
        
        view.addSubview(rangeSlider)
        _ = rangeSlider.anchor(pickerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 8, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 30)
    }
    
    private func prepareTableView() {
        tableView = UITableView(frame: .zero)
        tableView.dataSource = viewModel
        tableView.delegate = viewModel
        tableView.register(RoomCell.self, forCellReuseIdentifier: RoomCell.identifier)
        tableView.tableFooterView = UIView()
        
        view.addSubview(tableView)
        _ = tableView.anchor(rangeSlider.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 8, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    
    private func prepareEmptyView() {
        emptyView = EmptyView()
        emptyView.isHidden = true
        
        view.addSubview(emptyView)
        _ = emptyView.anchor(tableView.topAnchor, left: tableView.leftAnchor, bottom: tableView.bottomAnchor, right: tableView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    
    private func prepareBarButton() {
        barButton = UIBarButtonItem(title: barButtonTitle, style: .done, target: self, action: #selector(handleBarButtonPressed(_:)))
        navigationItem.rightBarButtonItem = barButton
    }
}

// MARK: - Prepare View Model
extension GSROverhallController {
    fileprivate func prepareViewModel() {
        viewModel = GSRViewModel()
        viewModel.delegate = self
    }
}

// MARK: - ViewModelDelegate + Networking
extension GSROverhallController: GSRViewModelDelegate {
    func fetchData() {
        let locationId = viewModel.getSelectedLocation().id
        let date = viewModel.getSelectedDate()
        GSROverhaulManager.instance.getAvailability(for: locationId, date: date) { (rooms) in
            DispatchQueue.main.async {
                if let rooms = rooms {
                    self.viewModel.updateData(with: rooms)
                    self.refreshDataUI()
                    self.rangeSlider.reload()
                }
            }
        }
    }
    
    func refreshDataUI() {
        emptyView.isHidden = !viewModel.isEmpty
        tableView.isHidden = viewModel.isEmpty
        self.tableView.reloadData()
    }
    
    func refreshSelectionUI() {
        self.refreshBarButton()
    }
}

// MARK: - UIGestureRecognizerDelegate
extension GSROverhallController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view == rangeSlider || touch.location(in: tableView).y > 0 {
            return false
        }
        return true
    }
}

// MARK: - Bar Button Refresh + Handler
extension GSROverhallController {
    fileprivate func refreshBarButton() {
        self.barButton.tintColor = .clear
        barButton.title = barButtonTitle
        self.barButton.tintColor = nil
    }
    
    @objc fileprivate func handleBarButtonPressed(_ sender: Any) {
        switch viewModel.state {
        case .loggedOut:
            break
        case .loggedIn:
            break
        case .readyToSubmit:
            break
        }
    }
}
