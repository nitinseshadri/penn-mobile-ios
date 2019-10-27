//
//  GSRGroupViewModel.swift
//  PennMobile
//
//  Created by Rehaan Furniturewala on 10/20/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

protocol GSRManageGroupViewModelDelegate {
    //TODO: Add stuff here
}

enum GSRGroupPermissions { //who has access
    case everyone
    case owner
}

class GSRManageGroupViewModel: NSObject {
    //store important data used by gsr group views
    fileprivate var group: GSRGroup!
    fileprivate var settings = [String:String]() //todo change type of settings
    
    // MARK: Delegate
    var delegate: GSRManageGroupViewModelDelegate!
     
    // MARK: init
    init(group: GSRGroup) {
        self.group = group
    }
}

//MARK: UITableViewDataSource
extension GSRManageGroupViewModel: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return settings.count
        } else {
            return group.members.count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Settings"
        } else {
            return "Members"
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GroupMemberCell.identifier, for: indexPath) as! GroupMemberCell
        cell.member = group.members[indexPath.row]
        return cell
    }
    
    
}

//MARK: UITableViewDelegate
extension GSRManageGroupViewModel: UITableViewDelegate {
    
}
