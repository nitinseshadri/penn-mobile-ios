//
//  LabsLoginController.swift
//  PennMobile
//
//  Created by Josh Doman on 12/11/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation
import WebKit
import SwiftyJSON
#if canImport(CryptoKit)
import CryptoKit
#endif
import CommonCrypto

enum SHA256Encoding {
    case base64
    case hex
}

protocol SHA256Hashable {}

extension SHA256Hashable {
    func hash(string: String, encoding: SHA256Encoding) -> String {
        let inputData = Data(string.utf8)
#if canImport(CryptoKit)
        let digest = SHA256.hash(data: inputData)
        switch encoding {
        case .base64:
            return Data([UInt8](digest.makeIterator())).base64EncodedString()
        case .hex:
            return digest.compactMap { String(format: "%02x", $0) }.joined()
        }
#else
        return commonCryptoHash(inputData: inputData, encoding: encoding)
#endif
    }

    private func commonCryptoHash(inputData: Data, encoding: SHA256Encoding) -> String {
        // https://www.agnosticdev.com/content/how-use-commoncrypto-apis-swift-5
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        _ = inputData.withUnsafeBytes {
            CC_SHA256($0.baseAddress, UInt32(inputData.count), &digest)
        }

        switch encoding {
        case .base64:
            return Data([UInt8](digest.makeIterator())).base64EncodedString()
        case .hex:
            return digest.compactMap { String(format: "%02x", $0) }.joined()
        }
    }
}

class LabsLoginController: PennLoginController, IndicatorEnabled, Requestable, SHA256Hashable {

    private var clientID = InfoPlistEnvironment.labsOauthClientId

    override var urlStr: String {
        return "https://platform.pennlabs.org/accounts/authorize/?response_type=code&client_id=\(clientID)&redirect_uri=https%3A%2F%2Fpennlabs.org%2Fpennmobile%2Fios%2Fcallback%2F&code_challenge_method=S256&code_challenge=\(codeChallenge)&scope=read+introspection&state="
    }

    override var shouldLoadCookies: Bool {
        return false
    }

    private let codeVerifier = String.randomString(length: 64)

    private var codeChallenge: String {
        var challenge = hash(string: codeVerifier, encoding: .base64)
        challenge.removeAll(where: { $0 == "=" })
        challenge = challenge.replacingOccurrences(of: "+", with: "-")
        challenge = challenge.replacingOccurrences(of: "/", with: "_")
        return challenge
    }

    private var code: String?

    private var shouldRetrieveRefreshToken = true
    private var shouldFetchAllInfo: Bool!
    private var completion: ((_ success: Bool) -> Void)!

    convenience init(fetchAllInfo: Bool = true, shouldRetrieveRefreshToken: Bool = true, completion: @escaping (_ success: Bool) -> Void) {
        self.init()
        self.completion = completion
        self.shouldFetchAllInfo = fetchAllInfo
        self.shouldRetrieveRefreshToken = shouldRetrieveRefreshToken
    }

    convenience init(fetchAllInfo: Bool = true) {
        self.init()
        self.completion = ({ _ in })
        self.shouldFetchAllInfo = fetchAllInfo
    }

    private init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func handleDefaultLogin(decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

        let account = Account(pennid: 12345678, firstName: "Ben", lastName: "Franklin", username: "bfranklin", email: "benfrank@wharton.upenn.edu", student: Student(major: [], school: []), groups: [], emails: [])
        Account.saveAccount(account)

        OAuth2NetworkManager.instance.saveAccessToken(accessToken: AccessToken(value: "root", expiration: Calendar.current.date(byAdding: .month, value: 1, to: Date())!))
        OAuth2NetworkManager.instance.saveRefreshToken(token: "123456789")
        decisionHandler(.cancel)
        self.dismiss(successful: true)
    }

    override func handleSuccessfulNavigation(_ webView: WKWebView, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard shouldRetrieveRefreshToken else {
            // Refresh token does not to be retrieved. Dismiss controller immediately.
            decisionHandler(.cancel)
            self.dismiss(successful: true)
            return
        }

        guard let code = code else {
            // Something went wrong, code not fetched
            decisionHandler(.cancel)
            self.dismiss(successful: false)
            return
        }

        decisionHandler(.cancel)
        self.showActivity()
        OAuth2NetworkManager.instance.initiateAuthentication(code: code, codeVerifier: codeVerifier) { (accessToken) in
            guard let accessToken = accessToken else {
                self.dismiss(successful: false)
                return
            }
            guard self.shouldFetchAllInfo else {
                self.dismiss(successful: true)
                return
            }
            OAuth2NetworkManager.instance.retrieveAccount(accessToken: accessToken) { (account) in
                guard let account = account else {
                    self.dismiss(successful: false)
                    return
                }

                UserDefaults.standard.saveAccount(account)
                UserDefaults.standard.set(isInWharton: account.isInWharton)

                UserDBManager.shared.syncUserSettings { (_) in
                    self.saveAccount(account) {
                        self.dismiss(successful: true)
                    }
                }
            }
        }
    }

    func dismiss(successful: Bool) {
        DispatchQueue.main.async {
            if successful {
                UserDefaults.standard.setLastLogin()
            }
            UserDefaults.standard.storeCookies()
            self.hideActivity()
            super.dismiss(animated: true, completion: nil)
            self.completion(successful)
        }
    }

    override func isSuccessfulRedirect(url: String, hasReferer: Bool) -> Bool {
        let targetUrl = "https://pennlabs.org/pennmobile/ios/callback/?code="
        if url.contains(targetUrl) {
            if let code = url.split(separator: "=").last {
                self.code = String(code)
            }
            return true
        }
        return false
    }
}

// MARK: - Save Student {
extension LabsLoginController {
    fileprivate func saveAccount(_ account: Account, _ callback: @escaping () -> Void) {
        Account.saveAccount(account)
        UserDBManager.shared.saveAccount(account) { (accountID) in
            if let accountID = accountID {
                UserDefaults.standard.set(accountID: accountID)
            }
            callback()

            if accountID == nil {
                FirebaseAnalyticsManager.shared.trackEvent(action: "Attempt Login", result: "Failed Login", content: "Failed Login")
            } else {
                FirebaseAnalyticsManager.shared.trackEvent(action: "Attempt Login", result: "Successful Login", content: "Successful Login")

                if account.isStudent {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        if UserDefaults.standard.getPreference(for: .collegeHouse) {
                            CampusExpressNetworkManager.instance.updateHousingData()
                        }
                        self.getDiningTransactions()
                        self.getAndSaveLaundryPreferences()
                        self.getPacCode()
                    }
                }
            }
        }
    }
}

// MARK: - Retrieve Other Account Information
extension LabsLoginController {
    fileprivate func getDiningTransactions() {
        PennCashNetworkManager.instance.getTransactionHistory { data in
            if let data = data, let str = String(bytes: data, encoding: .utf8) {
                UserDBManager.shared.saveTransactionData(csvStr: str)
                UserDefaults.standard.setLastTransactionRequest()
            }
        }
    }

    fileprivate func getAndSaveLaundryPreferences() {
        UserDBManager.shared.getLaundryPreferences { rooms in
            if let rooms = rooms {
                UserDefaults.standard.setLaundryPreferences(to: rooms)
            }
        }
    }

    fileprivate func getPacCode() {
        PacCodeNetworkManager.instance.getPacCode { result in
            switch result {
            case .success(let pacCode):
                KeychainAccessible.instance.savePacCode(pacCode)
            case .failure:
                return
            }
        }
    }

    fileprivate func getAndSaveNotificationAndPrivacyPreferences(_ completion: @escaping () -> Void) {
        UserDBManager.shared.syncUserSettings { (_) in
            completion()
        }
    }

    fileprivate func obtainCoursePermission(_ callback: @escaping (_ granted: Bool) -> Void) {
        self.hideActivity()
        let title = "\"Penn Mobile\" Would Like To Access Your Courses"
        let message = "Access is needed to display your course schedule on the app."
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Don't Allow", style: .default, handler: { (_) in
            callback(false)
        }))
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            callback(true)
        }))
        present(alert, animated: true)
    }
}

extension Set where Element == Degree {
    func hasDegreeInWharton() -> Bool {
        return self.contains { (degree) -> Bool in
            return degree.schoolCode == "WH"
        }
    }
}
