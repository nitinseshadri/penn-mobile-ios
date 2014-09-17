//
//  MenuViewController.h
//  PennMobile
//
//  Created by Sacha Best on 9/11/14.
//  Copyright (c) 2014 PennLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FoodItemTableViewCell.h"

@interface MenuViewController : UITableViewController

/**
 * Food is an array of stations - each station is an NSDictionary with an entry in 
 * @"station" with the name of the station and then there is another NSDictionary
 * with the food items in it.
 * This implementation is somewhat precarious but gets the job done for now. 
 **/
@property NSArray *food;



- (void)populateSectionTypes;

@end
