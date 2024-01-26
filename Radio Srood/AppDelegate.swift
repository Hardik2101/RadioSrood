

import UIKit
import CoreData
import OneSignal
import GoogleMobileAds
import AVKit
import StoreKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var player: Player!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        UserDefaults.standard.removeObject(forKey: "NowPlayData")

        
        IAPHandler.shared.setProductIds(ids: [
            IAProduct.Product_identifierOneMonth.rawValue,
            IAProduct.Product_identifierYearly.rawValue])
        
        IAPHandler.shared.fetchAvailableProducts { (products)   in
            if products.count != 0 {
                IAPHandler.shared.productArray = products
            }
        }
        
        if let exprDate = getObjectValueFromUserDefaults_ForKey( UserDefaultKeys.CommanKeys.SubscriptionDate.string) as? Date {
            if Date().isGreaterThan(exprDate) {
                IAPHandler.shared.receiptValidation()
            } else {
                IAPHandler.shared.receiptValidation()
            }
        } else {
            IAPHandler.shared.receiptValidation()
        }

        OneSignal.initWithLaunchOptions(launchOptions)
        OneSignal.setAppId (ONESIGNAL_APP_KEY)
//       OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification
        
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        AppOpenAdManager.shared.loadAd()
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
        let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        UIApplication.shared.registerUserNotificationSettings(settings)
        
        UIApplication.shared.registerForRemoteNotifications()
        application.registerForRemoteNotifications()
        
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
        try? AVAudioSession.sharedInstance().setActive(true)
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
      let rootViewController = application.windows.first(
        where: { $0.isKeyWindow })?.rootViewController
      if let rootViewController = rootViewController {
          AppOpenAdManager.shared.showAdIfAvailable(viewController: rootViewController)
        // Do not show app open ad if the current view controller is SplashViewController.
      }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
     
    }

    
    
    override func remoteControlReceived(with event: UIEvent?) {
        
       /* if (player.isPlayings){
            
            print("IS PLAYNG - - - - -")
            
        } else {
            
            if event!.type == .remoteControl {
                switch event!.subtype {
                case .remoteControlPlay:
                    AudioPlayer.sharedAudioPlayer.resume()
                case .RemoteControlPause:
                    AudioPlayer.sharedAudioPlayer.pause()
                case .RemoteControlTogglePlayPause:
                    AudioPlayer.sharedAudioPlayer.togglePlayPause()
                case .RemoteControlPreviousTrack:
                    AudioPlayer.sharedAudioPlayer.previousTrack(true)
                case .RemoteControlNextTrack:
                    AudioPlayer.sharedAudioPlayer.nextTrack(true)
                default: break
                }
            }
        } */
    }

    

}

