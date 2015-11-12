import UIKit
import CoreTelephony
import CheckMobiSwift

private func showMessageBox(title: String, message: String, tag: Int, delegate: AnyObject?) {
    let alertView = UIAlertView(title: title, message: message, delegate: delegate, cancelButtonTitle: "OK")
    alertView.tag = tag
    alertView.show()
}

class ViewController: UIViewController {
    @IBOutlet var validationType: UISegmentedControl!
    @IBOutlet var validationNumber: UITextField!
    @IBOutlet var validationPin: UITextField!
    @IBOutlet var validationButton: UIButton!
    @IBOutlet var resetButton: UIButton!
    @IBOutlet var callChargeLabel: UILabel!
    
    private var callId: String?
    private var dialingNumber: String?
    private var validationKey: String?
    private var pinStep = false
    private var callCenter: CTCallCenter?

    override func viewDidLoad() {
        super.viewDidLoad()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: NSSelectorFromString("checkCallState"), name: UIApplicationDidBecomeActiveNotification, object: nil)
        
        registerForCalls()
        refreshGUI()
        
    }
    
     deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidBecomeActiveNotification, object: nil)
    }
    
    func checkCallState() {
        if dialingNumber == nil || validationKey == nil || callId == nil {
            return
        }
        var found = false
        let center = CTCallCenter()
        if center.currentCalls != nil {
            for call in center.currentCalls! {
                if call.callID == callId {
                    found = true
                    break
                }
            }
        }
        
        if !found {
            callCompleted(callId!)
        }
    }
    
    func callInitiated(callId: String) {
        if dialingNumber == nil || validationKey == nil || self.callId != nil {
            return
        }
        self.callId = callId
    }
    
    func callCompleted(callId: String) {
        if dialingNumber == nil || validationKey == nil || self.callId == nil {
            return
        }
        if self.callId != callId {
            return
        }
    
        CheckMobiService.sharedInstance.checkValidationStatus(requestId: validationKey!) { (status: CMVerificationStatus?, error: NSError?) -> () in
            
            self.dialingNumber = nil
            self.validationKey = nil
            self.callId = nil
            
            if let status = status {
                if !status.validated {
                    showMessageBox("Error", message: "Number not validated ! Check your phone number!", tag: 0, delegate: nil)
                    return
                }
                showMessageBox("Validation completed", message: "Validation completed for: \(status.number)", tag: 0, delegate: nil)
                self.OnReset(nil)
            } else {
                self.handleValidationServiceError(error)
            }
        }
    }
    
    func registerForCalls()  {
        callCenter = CTCallCenter()
        callCenter?.callEventHandler = { [weak self] (call: CTCall!) -> () in
            if call.callState == CTCallStateDialing {
                dispatch_async(dispatch_get_main_queue(), {
                    self?.callInitiated(call.callID)
                })
            } else if call.callState == CTCallStateDisconnected {
                dispatch_async(dispatch_get_main_queue(), {
                    self?.callCompleted(call.callID)
                })
            }
        }
    }
    
    func getCurrentValidationType() -> CMValidationType {
        switch self.validationType.selectedSegmentIndex {
            case 0:
                return .CLI
            case 1:
                return .SMS
            case 2:
                return .IVR
            default:
                return .ReverseCLI
        }
    }
    
    @IBAction func OnValidate(sender: AnyObject?)  {
        if CheckMobiService.sharedInstance.secretKey == "" {
            showMessageBox("Error", message: "API secret key is not specified", tag: 0, delegate: nil)
            return
        }
        
        if !pinStep {
            if validationNumber.text == "" {
                showMessageBox("Invalid number", message: "Please provide a valid number", tag: 0, delegate: nil)
                return
            }
            
            validationNumber.resignFirstResponder()
            
            CheckMobiService.sharedInstance.requestValidation(type: getCurrentValidationType(), number: validationNumber.text!, callback: { (response: CMValidationResponse?, error: NSError?) -> () in
                
                if error == nil && response != nil {
                    let key = response!.id
                    let type = response!.type
                    
                    self.validationNumber.text = response!.validationInfo.formatting
                    
                    if type == .CLI {
                        self.performCliValidation(key, destinationNo: response!.dialingNumber!)
                    } else {
                        self.performPinValidation(key)
                    }
                } else {
                    self.handleValidationServiceError(error)
                }
            })
        } else {
            if self.validationPin.text == "" {
                showMessageBox("Invalid pin", message: "Please provide a valid pin number", tag: 0, delegate: nil)
                return
            }
            
            self.validationPin.resignFirstResponder()
            
            CheckMobiService.sharedInstance.verifyPin(requestId: validationKey!, pin: validationPin.text!, callback: { (verificationStatus: CMVerificationStatus?, error: NSError?) -> () in
                    
                    if error == nil && verificationStatus != nil {
                        if !verificationStatus!.validated {
                            showMessageBox("Error", message: "Invalid PIN!", tag: 0, delegate: nil)
                            return
                        }
                        
                        showMessageBox("Validation completed", message: "Validation completed for:\(self.validationNumber.text!)", tag: 0, delegate: nil)
                        self.OnReset(nil)
                    } else {
                        self.handleValidationServiceError(error)
                    }
            })
        }
    }
    
    func performCliValidation(key: String, destinationNo: String) {
        validationKey = key
        dialingNumber = destinationNo
        let phoneURLString = "tel://\(destinationNo)"
        let phoneURL = NSURL(string: phoneURLString)!
        UIApplication.sharedApplication().openURL(phoneURL)
    }
    
    func performPinValidation(key: String) {
        validationKey = key
        pinStep = true
        refreshGUI()
    }
    
    @IBAction func OnValidationTypeChanged(sender: AnyObject?) {
        refreshGUI()
    }
    
    @IBAction func OnReset(sender: AnyObject?) {
        callId = nil
        dialingNumber = nil
        validationKey = nil
        pinStep = false
        validationPin.text = ""
        validationNumber.text = ""
        refreshGUI()
    }
    
    func handleValidationServiceError(error: NSError?) {
        if error == nil {
            return
        }
        if let errorCode = CMErrorCode(rawValue: error!.code) {
            var errorMessage: String
            switch errorCode {
                case .InvalidPhoneNumber:
                    errorMessage = "Invalid phone number. Please provide the number in E164 format."
                default:
                    errorMessage = "Service unavailable. Please try later."
            }
            showMessageBox("Error", message: errorMessage, tag: 0, delegate: nil)
        } else {
            showMessageBox("Error", message: "Service unavailable. Please try later.", tag: 0, delegate: nil)
        }
    }
    
    func refreshGUI() {
        if pinStep {
            validationButton.setTitle("Submit PIN", forState: .Normal)
        } else {
            validationButton.setTitle("Validate", forState: .Normal)
        }
        validationNumber.enabled = !pinStep
        validationType.enabled = !pinStep
        validationPin.hidden = !pinStep
        resetButton.hidden = !pinStep
        callChargeLabel.hidden = validationType.selectedSegmentIndex != 0
    }

}
