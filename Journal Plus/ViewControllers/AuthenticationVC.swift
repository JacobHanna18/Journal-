//
//  AuthenticationVC.swift
//  Journal Plus
//
//  Created by Jacob Hanna on 30/12/2020.
//  Copyright © 2020 Jacob Hanna. All rights reserved.
//

import UIKit
import LocalAuthentication

class AuthenticationVC: UIViewController {

    var context = LAContext()
    static let segID = "AuthenticateSuccessSegue"
    
    func authenticate(){
        context = LAContext()

        // First check if we have the needed hardware support.
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {

            let reason = "Enter Journal!"
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason ) { success, error in

                if success {

                    // Move to the main thread because a state update triggers UI changes.
                    DispatchQueue.main.async { [unowned self] in
                        self.performSegue(withIdentifier: AuthenticationVC.segID, sender: self)
                    }

                } else {
                    DispatchQueue.main.async { [unowned self] in
                        let alert = UIAlertController(title: "Authentication Failed", message: nil, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Try Again", style: .default, handler: {_ in
                            self.authenticate()
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        } else {
            context.invalidate()
            let alert = UIAlertController(title: "You hav not set a password on this device", message: "We will turn off your secure app authentication, you will need to add a passcode or biometry authentication on the device to access this feature.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (a) in
                DispatchQueue.main.async { [unowned self] in
                    self.performSegue(withIdentifier: AuthenticationVC.segID, sender: self)
                }
            }))
            self.present(alert, animated: true, completion: nil)

        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if Authentication.Enable.value{
            authenticate()
        }else{
            self.performSegue(withIdentifier: AuthenticationVC.segID, sender: self)
        }
        
    }
    
    override func viewDidLoad() {
        
    }
}
