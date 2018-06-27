//
//  BuildingFoodMenuCell.swift
//  PennMobile
//
//  Created by dominic on 6/26/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import UIKit

class BuildingFoodMenuCell: BuildingCell {
    
    static let identifier = "BuildingFoodMenuCell"
    static let cellHeight: CGFloat = 188
    static let numDays: Int = 7
    
    override var venue: DiningVenue! {
        didSet {
            setupCell(with: venue)
        }
    }
    
    fileprivate let safeInsetValue: CGFloat = 14
    fileprivate var safeArea: UIView!
    
    fileprivate var dayLabels: [UILabel]!
    fileprivate var hourLabels: [UILabel]!
    
    // MARK: - Init
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        prepareUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup Cell
extension BuildingFoodMenuCell {
    
    fileprivate func setupCell(with venue: DiningVenue) {
    }
}

// MARK: - Initialize and Prepare UI
extension BuildingFoodMenuCell {
    
    fileprivate func prepareUI() {
        prepareSafeArea()
        
        dayLabels = [UILabel](); hourLabels = [UILabel]()
        
        for _ in 0 ..< BuildingFoodMenuCell.numDays {
            dayLabels.append(getDayLabel())
            hourLabels.append(getHourLabel())
        }
        layoutLabels()
    }
    
    // MARK: Safe Area
    fileprivate func prepareSafeArea() {
        safeArea = getSafeAreaView()
        addSubview(safeArea)
        NSLayoutConstraint.activate([
            safeArea.leadingAnchor.constraint(equalTo: leadingAnchor, constant: safeInsetValue),
            safeArea.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -safeInsetValue),
            safeArea.topAnchor.constraint(equalTo: topAnchor, constant: safeInsetValue),
            safeArea.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -safeInsetValue)
            ])
    }
    
    // MARK: Layout Labels
    fileprivate func layoutLabels() {
        for day in 0 ..< BuildingFoodMenuCell.numDays {
            let dayLabel = dayLabels[day]
            let hourLabel = hourLabels[day]
            
            addSubview(dayLabel)
            addSubview(hourLabel)
            
            if day == 0 {
                _ = dayLabel.anchor(safeArea.topAnchor, left: safeArea.leftAnchor, bottom: nil, right: nil)
                _ = hourLabel.anchor(safeArea.topAnchor, left: nil, bottom: nil, right: safeArea.rightAnchor)
            } else {
                _ = dayLabel.anchor(dayLabels[day - 1].bottomAnchor, left: safeArea.leftAnchor, topConstant: safeInsetValue)
                _ = hourLabel.anchor(hourLabels[day - 1].bottomAnchor, right: safeArea.rightAnchor, topConstant: safeInsetValue)
            }
        }
    }
    
    fileprivate func getDayLabel() -> UILabel{
        let label = UILabel()
        label.font = .interiorTitleFont
        label.textColor = UIColor.informationYellow
        label.textAlignment = .left
        label.text = "Day"
        return label
    }
    
    fileprivate func getHourLabel() -> UILabel{
        let label = UILabel()
        label.font = .interiorTitleFont
        label.textColor = UIColor.informationYellow
        label.textAlignment = .right
        label.text = "Hour"
        return label
    }
    
    fileprivate func getSafeAreaView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
}
