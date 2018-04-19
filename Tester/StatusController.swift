//
//  StatusController.swift
//  Tester
//
//  Created by Nikki Wines on 4/9/18.
//  Copyright © 2018 Kai Banks. All rights reserved.
//

import UIKit
import CoreNFC
class StatusController: UIViewController, NFCNDEFReaderSessionDelegate {
    let defaults = UserDefaults.standard
    var nfcSession: NFCNDEFReaderSession!
        var photon : SparkDevice?
        var lockStatus : String = "unlocked"
    
        @IBOutlet weak var toggleValue: UISwitch!
        @IBOutlet weak var toggleLabel: UILabel!
        @IBOutlet weak var doorStatusLabel: UILabel?
        @IBOutlet weak var deviceNameLabel: UILabel!
        @IBOutlet weak var userEmailLabel: UILabel!
        @IBOutlet weak var doorToggle: UISwitch!
    
        @IBOutlet weak var popupHorizontalConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var popupVerticleConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        /* verify device and begin nfc session */
        loadDevice();
       // nfcSession = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
       // nfcSession.begin()
    }
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        print("The session was invalidated: \(error.localizedDescription)")
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        print("NFC Tag detected:")
        
        for message in messages {
            for record in message.records {
                print(record.payload)
            }
        }
    }
    
    //    func reloadSession() {
    //        nfcSession = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
    //        nfcSession.begin()
    //    }

        func loadDevice() {
            SparkCloud.sharedInstance().getDevices { (devices:[SparkDevice]?, error:Error?) -> Void in
                if let _ = error {
                    print("Check your internet connectivity")
                }
                else {
                    if let d = devices {
                        for device in d{
                            if device.name == "bacon_wizard" {
                                self.photon = device
                                self.deviceNameLabel.text = device.name
                                self.userEmailLabel.text = SparkCloud.sharedInstance().loggedInUsername
                                self.checkDoorStatus()
                            }
                        }
                    }
                }
            }
        }
    
        /* Check Door Status:
         * Query the particle console to obtain current lock/unlocked status for door.
         * Update labels accordingly.
         */
        func checkDoorStatus() {
            print("getting status")
            let funcArgs = ["Door1"]
            let _ = photon!.callFunction("getStatus", withArguments: funcArgs) { (resultCode : NSNumber?, error : Error?) -> Void in
                print("checkDoorStatus:", resultCode ?? 999)
                if let _ = error {
                    print("Failed reading doorstatus from device")
                }
                else {
                    if resultCode == 1 {
                        self.lockStatus = "locked"
                        self.doorToggle.isOn = true
                        self.doorStatusLabel?.text = "Locked"
                        self.doorStatusLabel?.textColor = UIColor.green
                        self.toggleLabel?.text = "Unlock Door"
                    }
                    else {
                        self.lockStatus = "unlocked"
                        self.doorToggle.isOn = false
                        self.doorStatusLabel?.text = "Unlocked"
                        self.doorStatusLabel?.textColor = UIColor.red
                        self.toggleLabel?.text = "Lock Door"
    
    
                    }
                }
                print(self.lockStatus)
            }
        }
        /* Refresh Clicked:
         * manually rechecks door status via func checkDoorStatus
         */
        @IBAction func Refreshclicked(_ sender: UIButton) {
            checkDoorStatus()
        }
    
        /* Toggle Door Status:
         * Manually alter door's locked/unlocked status by sending a request to the particle console.
         *
         */
        @IBAction func toggleDoorStatus(_ sender: UISwitch) {
            let funcArgs = ["Door1"]
            let _ = photon!.callFunction("toggleLock", withArguments: funcArgs) { (resultCode : NSNumber?, error : Error?) -> Void in
                print("result code: ", resultCode ?? 999)
                if (error == nil) {
                    print("Door succesfully toggled")
                    self.checkDoorStatus()
                }
            }
        }
    
    
        /* Settings Clicked:
         * Load settings popup.
         */
        @IBAction func settingsClicked(_ sender: UIButton) {
            print("settings clicked")
            popupHorizontalConstraint.constant = 112
            popupVerticleConstraint.constant = 44

            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            })
    
        }
        /* Settings Closed:
         * Remove settings popup.
         */
        @IBAction func settingsClose(_ sender: Any) {
            popupHorizontalConstraint.constant = 400
            popupVerticleConstraint.constant = 44
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            })
        }
        /* Logout:
         * End user session and segue back to login page.
         */
        @IBAction func logout(_sender: UIButton) {
            SparkCloud.sharedInstance().logout()
            performSegue(withIdentifier: "logout segue", sender: self)
            defaults.set(0, forKey: "loggedin")
            print("Logged Out")
            
        }
    
}
