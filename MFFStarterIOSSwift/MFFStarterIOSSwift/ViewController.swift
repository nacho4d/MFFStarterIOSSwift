//
//  ViewController.swift
//  MFFStarterIOSSwift
//
//  Created by Ignacio on 2018/05/16.
//  Copyright © 2018 Ignacio. All rights reserved.
//

import UIKit

import IBMMobileFirstPlatformFoundation

class ViewController: UIViewController {

    @IBOutlet var testServerButton: UIButton!
    @IBOutlet var getUserDisplayButton: UIButton!
    @IBOutlet var getUserDisplayBinaryDelegateButton: UIButton!
    @IBOutlet var logoutButton: UIButton!

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var connectionStatusLabel: UILabel!

    var mffChallengeHandler: MFFChallengeHandler?

    override func viewDidLoad() {
        super.viewDidLoad()

        mffChallengeHandler = MFFChallengeHandler(securityCheck: MFFChallengeHandler.realm)
        WLClient.sharedInstance().registerChallengeHandler(mffChallengeHandler)
        logout(sender: nil)
    }

    @IBAction func getAccessToken(sender: UIButton) {
        let serverURL = WLClient.sharedInstance().serverUrl()!
        connectionStatusLabel.text = "Connecting to server...\n\(serverURL)"
        print("Testing Server Connection")

        self.view.isUserInteractionEnabled = false
        WLAuthorizationManager.sharedInstance().obtainAccessToken(forScope: nil) { (token, error) -> Void in
            self.view.isUserInteractionEnabled = true

            if (error != nil) {
                self.titleLabel.text = "Bummer..."
                self.connectionStatusLabel.text = "Failed to connect to MobileFirst Server\n\(serverURL)"
                print("Did not recieve an access token from server: " + error.debugDescription)
            } else {
                self.titleLabel.text = "Yay!"
                self.connectionStatusLabel.text = "Connected to MobileFirst Server\n\(serverURL)"
                print("Recieved the following access token value: " + (token?.value ?? "null"))
            }
        }
    }

    @IBAction func getUserDisplayName(sender: UIButton) {

        let serverURL = WLClient.sharedInstance().serverUrl()!
        let url = serverURL.appendingPathComponent("adapters/Questionnaire/ipad/enter")
        let request : WLResourceRequest = WLResourceRequest(url: url, method: WLHttpMethodPost)
        request.addHeaderValue("application/json" as NSObject, forName:"Accept")

        self.view.isUserInteractionEnabled = false
        request.send { (response, error) in
            self.view.isUserInteractionEnabled = true

            if let error = error {
                self.titleLabel.text = "Bummer..."
                self.connectionStatusLabel.text = error.localizedDescription
                return
            }
            guard let response = response else {
                self.titleLabel.text = "Bummer..."
                self.connectionStatusLabel.text = "No response"
                return
            }
            let json = response.getJson()?.debugDescription ?? ""
            self.titleLabel.text = "Yay!"
            self.connectionStatusLabel.text = json
        }
    }

    @IBAction func getUserDisplayNameViaBinaryDelegate(sender: UIButton) {
        let serverURL = WLClient.sharedInstance().serverUrl()!

        let url = serverURL.appendingPathComponent("adapters/Questionnaire/ipad/dl/10001/00/1")
        let request: WLResourceRequest = WLResourceRequest(url: url, method: WLHttpMethodGet)
        request.setQueryParameterValue("2018-05-26 00:00:00", forName: "timestamp")

        self.view.isUserInteractionEnabled = false
        let binaryDelegate = MFFBinaryDelegate { (data, error) in
            self.view.isUserInteractionEnabled = true
            if let error = error {
                self.titleLabel.text = "Bummer..."
                self.connectionStatusLabel.text = error.localizedDescription
                return
            }

            guard let data = data else {
                self.titleLabel.text = "Bummer..."
                self.connectionStatusLabel.text = "No response"
                return
            }
            self.titleLabel.text = "Yay!"
            self.connectionStatusLabel.text = "Received data length: \(data.count)"
        }
        request.send(withDelegate: binaryDelegate)
    }

    @IBAction func logout(sender: UIButton?) {
        self.view.isUserInteractionEnabled = false
        WLAuthorizationManager.sharedInstance().logout(MFFChallengeHandler.realm, withCompletionHandler: { (error) -> Void in
            self.view.isUserInteractionEnabled = true

            if let error = error {
                print("Could not logout " + error.localizedDescription)
                self.titleLabel.text = "Bummer..."
                self.connectionStatusLabel.text = error.localizedDescription
            }
            self.titleLabel.text = "Yay!"
            self.connectionStatusLabel.text = "Successfully logged out"
        })
    }
}

