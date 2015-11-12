import UIKit
import CheckMobiSwift

class SettingsController: UIViewController {
    @IBOutlet var baseUrlField: UITextField!
    @IBOutlet var secretKeyField: UITextField!
    @IBOutlet var smsLanguageField: UITextField!
    @IBOutlet var ivrLanguageField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        baseUrlField.text = CheckMobiService.sharedInstance.baseUrl
        smsLanguageField.text = CheckMobiService.sharedInstance.smsLanguage
        ivrLanguageField.text = CheckMobiService.sharedInstance.ivrLanguage
        secretKeyField.text = CheckMobiService.sharedInstance.secretKey
    }
    
    @IBAction func onClickCancel(sender: AnyObject?) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onClickSave(sender: AnyObject?) {
        if baseUrlField.text == "" || secretKeyField.text == "" {
            let alertView = UIAlertView(title: "Error", message: "Secret key and base url are empty!", delegate: nil, cancelButtonTitle: "OK")
            alertView.show()
            return
        }
        
        CheckMobiService.sharedInstance.baseUrl = baseUrlField.text!
        CheckMobiService.sharedInstance.secretKey = secretKeyField.text!
        CheckMobiService.sharedInstance.smsLanguage = smsLanguageField.text!
        CheckMobiService.sharedInstance.ivrLanguage = ivrLanguageField.text!
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(baseUrlField.text, forKey: "base_url")
        defaults.setObject(secretKeyField.text, forKey: "secret_key")
        defaults.setObject(ivrLanguageField.text, forKey: "ivr_lang")
        defaults.setObject(smsLanguageField.text, forKey: "sms_lang")
        defaults.synchronize()
        
        dismissViewControllerAnimated(true, completion: nil)
    }

}
