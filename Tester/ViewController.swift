//
//  ViewController.swift
//  Tester
//
//  Created by Nikki Wines on 4/8/18.
//  Copyright © 2018 Kai Banks. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var particleEmail: UITextField!
    @IBOutlet weak var particlePassword: UITextField!
    let defaults = UserDefaults.standard

    
    /* Default setup functions */
    override func viewDidLoad() {
        super.viewDidLoad()
        print("defaults: ", defaults.bool(forKey: "loggedin"))
        if (defaults.bool(forKey: "loggedin")) {
           self.performSegue()
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("defaults: ", defaults.bool(forKey: "loggedin"))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    /* Login Function:
     * Utelizes particle functionality to securely log in user with their particle account
     */
    @IBAction func particleLogin(_ sender: UIButton) {
        let email = particleEmail.text
        let password = particlePassword.text
        SparkCloud.sharedInstance().login(withUser: email!, password: password!) { (error:Error?) -> Void in
            if let _ = error {
                print("Wrong credentials or no internet connectivity, please try again")
            }
            else {
                print("Error: ", error as Any)
                self.defaults.set(1, forKey: "loggedin")
                self.defaults.set(email, forKey: "email")
                self.defaults.set(password, forKey: "password")
                print("Logged in")
                self.performSegue()
            }

        }


    }
    
    /* Segue function:
     * Routes to main page
     */
    func performSegue() {
        performSegue(withIdentifier: "status segue", sender: self)
    }
}

