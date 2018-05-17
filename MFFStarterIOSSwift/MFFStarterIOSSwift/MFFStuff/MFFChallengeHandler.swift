//
//  ViewController+MFFChallengeHandler.swift
//  MFFStarterIOSSwift
//
//  Created by Ignacio on 2018/05/16.
//  Copyright © 2018 Ignacio. All rights reserved.
//

import UIKit
import IBMMobileFirstPlatformFoundation

class MFFChallengeHandler: SecurityCheckChallengeHandler {

    static let realm = "LDAPUserLogin"

    override func handleChallenge(_ challenge: [AnyHashable : Any]!) {
        print("handleChallenge " + challenge.debugDescription)

        if let errorMessage = challenge["errorMsg"] as? String {
            let message: String
            if let code = challenge["code"] as? Int,
                (code == 1 || //Username or password is incorrect
                    code == 2 || // Credentials are empty
                    code == 3) // UserID not found
            {
                message = "ユーザー名またはパスワードが正しくありません"
            } else {
                message = errorMessage.isEmpty ? "" : "ログイン失敗しました。\n\(errorMessage)"
            }
            // Maybe we should should remaining attempt "remainingAttempts"
            print("handleChallenge login failure " + message)
            showError(message)
            return
        }

        requireUserCredentials { (cancelled, credentials) in
            guard let credentials = credentials, !cancelled else {
                print("login cancelled")
                self.cancel()
                return
            }
            self.submitChallengeAnswer(["username": credentials.username,
                                   "password": credentials.password])
        }
        print("handleChallenge finished")
    }

    override func handleSuccess(_ success: [AnyHashable : Any]!) {
        print("handleSuccess " + success.debugDescription)
    }

    override func handleFailure(_ failure: [AnyHashable : Any]!) {
        print("handleFailure " + failure.debugDescription)
        showError("ログイン失敗しました。")
    }

    func showError(_ message: String) {
        guard let appDelegate = UIApplication.shared.delegate,
            let window = appDelegate.window,
            let vc = window?.rootViewController else {
                print("No window or root view controller found" + message)
                return
        }

        let alert = UIAlertController(title: message, message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Accept", style: .default) { (_) in
        })
        vc.present(alert, animated: true, completion: nil)
    }

    func requireUserCredentials(completion: @escaping ((_ cancelled: Bool, _ credentials: (username: String, password: String)?) -> Void)) {
        guard let appDelegate = UIApplication.shared.delegate,
            let window = appDelegate.window,
            let vc = window?.rootViewController else {
                print("Cannot require credentials. No window or root view controller found")
                completion(true, nil)
                return
        }

        let alert = UIAlertController(title: "Login", message: "Please enter you username and password", preferredStyle: .alert)
        alert.addTextField { (textfield) in
            textfield.placeholder = "username"
        }
        alert.addTextField{ (textfield) in
            textfield.placeholder = "password"
        }
        alert.addAction(UIAlertAction(title: "Go", style: .default) { (_) in
            let username = alert.textFields![0].text!
            let password = alert.textFields![1].text!
            completion(false, (username, password))
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            completion(true, nil)
        })
        vc.present(alert, animated: true, completion: nil)
    }
}
