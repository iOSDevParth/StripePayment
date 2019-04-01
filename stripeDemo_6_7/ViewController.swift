//
//  ViewController.swift
//  stripeDemo_6_7
//
//  Created by stegowl on 05/02/18.
//  Copyright © 2018 stegowl. All rights reserved.
//
// Stripe User Name & Password
// Email - pierceadamms.cis@gmail.com
// Pass - Crest@12345
// https://www.appcoda.com/ios-stripe-payment-integration/

import UIKit
import AFNetworking
import Stripe
import StoreKit

class ViewController: UIViewController {

    @IBOutlet weak var expireDateTextField: UITextField!
    @IBOutlet weak var cardNumberTextField: UITextField!
    @IBOutlet weak var cvcTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func pay(sender: AnyObject) {
        
        // Initiate the card
        let stripCard = STPCard()
        
        // Split the expiration date to extract Month & Year
        if self.expireDateTextField.text?.isEmpty == false {
            let myString: String = expireDateTextField.text!
            var myStringArr = myString.components(separatedBy: "/")
            //let expirationDate = self.expireDateTextField.text.componentsSeparatedByString("/")
            let expMonth = UInt(myStringArr[0])
            let expYear = UInt(myStringArr[1])
            
            // Send the card info to Strip to get the token
            stripCard.number = self.cardNumberTextField.text
            stripCard.cvc = self.cvcTextField.text
            stripCard.expMonth = expMonth!
            stripCard.expYear = expYear!
        }

        STPAPIClient.shared().createToken(with: stripCard, completion: { (token, error) -> Void in
            
            if error != nil {
                self.handleError(error: error! as NSError)
                return
            }
            
            self.postStripeToken(token: token!)
        })
        
        
    }
    
    func handleError(error: NSError) {
        let alert = UIAlertController(title: "Please Try Again", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
            switch action.style{
            case .default:
                print("Ok")
                
            case .cancel:
                print("cancel")
                
            case .destructive:
                print("destructive")
            }
        }))
        self.present(alert, animated: true, completion: nil)
   
    }
    
      func postStripeToken(token: STPToken) {
        
        let URL = "http://localhost/donate/payment.php"
        let params = ["stripeToken": token.tokenId,
                      "amount": Int(amountTextField.text!),
                      "currency": "usd",
                      "description": self.emailTextField.text] as [String : Any]
        
        let manager = AFHTTPRequestOperationManager()
        manager.post(URL, parameters: params, success: { (operation, responseObject) -> Void in
            
            if let response = responseObject as? [String: String] {
                
                let alert = UIAlertController(title: response["status"], message: response["message"], preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                    switch action.style{
                    case .default:
                        print("default")
                    case .cancel:
                        print("cancel")
                    case .destructive:
                        print("destructive")
                    }
                }))
                self.present(alert, animated: true, completion: nil)
                
            }
            
        }) { (operation, error) -> Void in
            self.handleError(error: error! as NSError)
        }
    }
    
    

}

