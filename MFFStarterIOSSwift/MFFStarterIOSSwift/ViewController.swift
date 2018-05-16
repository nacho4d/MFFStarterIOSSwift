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
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var connectionStatusLabel: UILabel!

    @IBAction func getAccessToken(sender: AnyObject) {
        self.testServerButton.isEnabled = false

        let serverURL = WLClient.sharedInstance().serverUrl()!

        connectionStatusLabel.text = "Connecting to server...\n\(serverURL)"
        print("Testing Server Connection")
        WLAuthorizationManager.sharedInstance().obtainAccessToken(forScope: nil) { (token, error) -> Void in

            if (error != nil) {
                self.titleLabel.text = "Bummer..."
                self.connectionStatusLabel.text = "Failed to connect to MobileFirst Server\n\(serverURL)"
                print("Did not recieve an access token from server: " + error.debugDescription)
            } else {
                self.titleLabel.text = "Yay!"
                self.connectionStatusLabel.text = "Connected to MobileFirst Server\n\(serverURL)"
                print("Recieved the following access token value: " + (token?.value ?? "null"))
            }

            self.testServerButton.isEnabled = true
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

