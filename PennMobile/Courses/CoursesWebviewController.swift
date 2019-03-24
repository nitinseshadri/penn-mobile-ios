//
//  CoursesWebviewController.swift
//  PennMobile
//
//  Created by Josh Doman on 3/23/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation
import WebKit

class CoursesWebviewController: PennLoginController, IndicatorEnabled {
    
    var currentTermOnly = true
    var completion: ((_ courses: Set<Course>?) -> Void)!
    
    override var urlStr: String {
        return "https://pennintouch.apps.upenn.edu/pennInTouch/jsp/fast2.do"
    }
    
    override func handleSuccessfulNavigation(_ webView: WKWebView, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        self.showActivity()
        PennInTouchNetworkManager.instance.getCourses(currentTermOnly: self.currentTermOnly) { (courses) in
            DispatchQueue.main.async {
                if let courses = courses {
                    decisionHandler(.cancel)
                    self.hideActivity()
                    self.saveCoursesAndDismiss(courses)
                } else {
                    // If unsuccessful, try one more time.
                    PennInTouchNetworkManager.instance.getCourses(currentTermOnly: true, callback: { (courses) in
                        DispatchQueue.main.async {
                            decisionHandler(.cancel)
                            self.hideActivity()
                            self.saveCoursesAndDismiss(courses)
                        }
                    })
                }
            }
        }
    }
    
    private func saveCoursesAndDismiss(_ courses: Set<Course>?) {
        if let courses = courses, let accountID = UserDefaults.standard.getAccountID() {
            UserDBManager.shared.saveCourses(courses, accountID: accountID)
            UserDBManager.shared.saveCourses(courses, accountID: accountID) { (_) in
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: {
                        self.completion(courses)
                    })
                }
            }
        }
        UserDefaults.standard.storeCookies()
    }
}
