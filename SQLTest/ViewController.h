//
//  ViewController.h
//  SQLTest
//
//  Created by Dzmitry Noska on 9/10/19.
//  Copyright © 2019 Dzmitry Noska. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>

@interface ViewController : UIViewController {
    sqlite3* contactDB;
}


@end

