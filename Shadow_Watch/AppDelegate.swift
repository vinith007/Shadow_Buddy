import UIKit
import UserNotifications
import FirebaseCore
import CoreLocation
import MessageUI
import FirebaseFirestore
import FirebaseAuth

class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, CLLocationManagerDelegate, MFMessageComposeViewControllerDelegate {
    
    var window: UIWindow?
    let locationManager = CLLocationManager()
    var userDetails: UserModel?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        fetchUserDetails()
        UNUserNotificationCenter.current().delegate = self
        setupNotificationActionsAndCategory()
        requestNotificationAuthorization()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        return true
    }
    
    func fetchUserDetails() {
            guard let userID = Auth.auth().currentUser?.uid else {
                print("No user is currently signed in.")
                return
            }
            
            let db = Firestore.firestore()
            db.collection("users").document(userID).getDocument { (document, error) in
                if let document = document, document.exists {
                    let data = document.data()
                    let fetchedUser = UserModel(
                        firstName: data?["firstName"] as? String ?? "",
                        lastName: data?["lastName"] as? String ?? "",
                        username: data?["username"] as? String ?? "",
                        sex: data?["sex"] as? String ?? "",
                        age: data?["age"] as? String ?? "",
                        minHeartRate: data?["minHeartRate"] as? String ?? "",
                        maxHeartRate: data?["maxHeartRate"] as? String ?? "",
                        contactNumber: data?["contactNumber"] as? String ?? ""
                    )
                    self.userDetails = fetchedUser
                    print("User details fetched successfully: \(fetchedUser)")
                } else {
                    print("Document does not exist or an error occurred: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
    
    private func setupNotificationActionsAndCategory() {
        let yesAction = UNNotificationAction(identifier: "YES_ACTION", title: "Yes", options: [.foreground])
        let noAction = UNNotificationAction(identifier: "NO_ACTION", title: "No", options: [.foreground])
        let category = UNNotificationCategory(identifier: "HEART_RATE_ALERT", actions: [yesAction, noAction], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
    
    
    private func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        switch response.actionIdentifier {
        case "YES_ACTION":
            print("The user needs help.")
            fetchUserLocationAndPrintURL()
        case "NO_ACTION":
            print("Thanks")
        default:
            break
        }
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
    
    
    func fetchUserLocationAndPrintURL() {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        case .notDetermined:
            print("Location authorization status not determined.")
        case .denied, .restricted:
            print("Location services are not authorized.")
        @unknown default:
            fatalError("Unknown authorization status.")
        }
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            print("Failed to get user location.")
            return
        }
        
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        
        // Apple Maps URL
        let appleMapsURL = "http://maps.apple.com/?ll=\(latitude),\(longitude)"
        
        // Google Maps URL
        let googleMapsURL = "https://www.google.com/maps/dir/?api=1&destination=\(latitude),\(longitude)"
        
  
        let messageBody: String
        if let firstName = userDetails?.firstName, let lastName = userDetails?.lastName {
            messageBody = "\(firstName) \(lastName) has set you as their emergency contact and needs help. \nUser's location (Apple Maps): \(appleMapsURL)\nUser's location (Google Maps): \(googleMapsURL)"
        } else {
            messageBody = "A user has set you as their emergency contact and needs help. \nUser's location (Apple Maps): \(appleMapsURL)\nUser's location (Google Maps): \(googleMapsURL)"
        }
        
        sendTextMessage(messageBody: messageBody)
    }

    func sendTextMessage(messageBody: String) {
        if MFMessageComposeViewController.canSendText() {
            let messageComposeVC = MFMessageComposeViewController()
            messageComposeVC.body = messageBody
            if let contactNumber = userDetails?.contactNumber, !contactNumber.isEmpty {
                       messageComposeVC.recipients = [contactNumber]
                   } else {
                       print("No contact number available.")
                       return
                   }
            messageComposeVC.messageComposeDelegate = self
            
          
            if let viewController = UIApplication.shared.windows.first?.rootViewController {
                viewController.present(messageComposeVC, animated: true, completion: nil)
            }
        } else {
            print("SMS services are not available.")
        }
    }

    // MFMessageComposeViewControllerDelegate method
    @objc func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }


    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user location with error: \(error.localizedDescription)")
    }
    
}
