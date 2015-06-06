//
//  PatternViewController.swift
//  Monies
//
//  Created by Daniel Green on 05/06/2014.
//  Copyright (c) 2014 Daniel Green. All rights reserved.
//

import UIKit
import LocalAuthentication
import OnePasswordExtension

class LockViewController: UITableViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var bankTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var memorableAnswerTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var unlockButton: UIButton!
    @IBOutlet weak var onePasswordButton: UIBarButtonItem!
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        loadLoginDetails()
        refreshUnlockButton()
        
        self.onePasswordButton.enabled = OnePasswordExtension.sharedExtension().isAppExtensionAvailable()
    }
    
    func loadLoginDetails() {
        if let bankType = LoginCredentials.sharedInstance.bankType {
            bankTypeSegmentedControl.selectedSegmentIndex = bankType.rawValue-1;
        } else {
            bankTypeSegmentedControl.selectedSegmentIndex = -1
        }
        
        loginTextField.text = LoginCredentials.sharedInstance.username
        memorableAnswerTextField.text = LoginCredentials.sharedInstance.memorableAnswer
        passwordTextField.text = LoginCredentials.sharedInstance.password
    }
    
    func refreshUnlockButton() {
        LoginCredentials.sharedInstance.bankType = BankType(rawValue: bankTypeSegmentedControl.selectedSegmentIndex+1)
        LoginCredentials.sharedInstance.username = loginTextField.text as String;
        LoginCredentials.sharedInstance.memorableAnswer = memorableAnswerTextField.text as String;
        LoginCredentials.sharedInstance.password = passwordTextField.text as String;
        
        unlockButton.enabled = LoginCredentials.sharedInstance.credentialsPresent()
    }
    
    @IBAction func unlockButtonPushed(sender: AnyObject) {
        LoginCredentials.sharedInstance.saveCredentials()
        
        touchId()
    }
    
    @IBAction func bankTypeSegmentedControlValueChanged(sender: AnyObject) {
        refreshUnlockButton()
    }
    
    @IBAction func onePasswordButtonPushed(sender: AnyObject) {
        OnePasswordExtension.sharedExtension().findLoginForURLString("https://www.hsbc.co.uk", forViewController: self, sender: sender, completion: { (loginDictionary, error) -> Void in
            if loginDictionary == nil {
                //if error!.code != Int(AppExtensionErrorCodeCancelledByUser) {
                if error!.code != Int(0) {
                    var alert = UIAlertController(title: "Error", message: String(format: "Error invoking 1Password App Extension for find login: %@", error!), preferredStyle: UIAlertControllerStyle.Alert)
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                return
            }
            
            self.loginTextField.text = loginDictionary?["username"] as? String
            // memorisable Answer?
            self.passwordTextField.text = loginDictionary?["password"] as? String
        })
    }
    
    func touchId() {
        let context = LAContext()
        var error : NSError?
        var myLocalizedReasonString = "Identify"
        
        // Allow devices without TouchID
        if !context.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error: &error) {
            allow()
            return
        }
        
        context.evaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, localizedReason: myLocalizedReasonString) { success, error in
            if success {
                Async.main(after: 0) { self.allow() }
            } else {
                Async.main(after: 5) { self.touchId() }
            }
        }
    }
    
    func allow() {
        performSegueWithIdentifier("unlock", sender: self)
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        refreshUnlockButton()
        return true;
    }
}
