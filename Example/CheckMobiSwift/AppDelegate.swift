import UIKit
import CheckMobiSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if let baseUrl = defaults.objectForKey("base_url") as? String {
            CheckMobiService.sharedInstance.baseUrl = baseUrl
        }
        if let secretKey = defaults.objectForKey("secret_key") as? String {
            CheckMobiService.sharedInstance.secretKey = secretKey
        }
        if let smsLang = defaults.objectForKey("sms_lang") as? String {
            CheckMobiService.sharedInstance.smsLanguage = smsLang
        }
        if let ivrLang = defaults.objectForKey("ivr_lang") as? String {
            CheckMobiService.sharedInstance.ivrLanguage = ivrLang
        }
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
    }

    func applicationDidEnterBackground(application: UIApplication) {
    }

    func applicationWillEnterForeground(application: UIApplication) {
    }

    func applicationDidBecomeActive(application: UIApplication) {
    }

    func applicationWillTerminate(application: UIApplication) {
    }


}

