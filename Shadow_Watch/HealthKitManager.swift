import HealthKit
import UserNotifications
import FirebaseFirestore
import FirebaseAuth

class HealthKitManager {
    static let shared = HealthKitManager()
    private let healthStore = HKHealthStore()
    var userDetails: UserModel?
    
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
    

    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, nil)
            return
        }
        
        let typesToRead: Set<HKObjectType> = [HKObjectType.quantityType(forIdentifier: .heartRate)!]
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            DispatchQueue.main.async {
                completion(success, error)
            }
        }
    }

    func fetchHeartRates(from startDate: Date, to endDate: Date, completion: @escaping ([HKQuantitySample]?) -> Void) {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            completion(nil)
            return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
        
        let query = HKSampleQuery(sampleType: heartRateType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { _, samples, error in
            DispatchQueue.main.async {
                completion(samples as? [HKQuantitySample])
            }
        }
        
        healthStore.execute(query)
    }

    func startMonitoringHeartRate() {
      fetchUserDetails()
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let query = HKObserverQuery(sampleType: heartRateType, predicate: nil) { query, completionHandler, error in
            guard error == nil else {
              
                completionHandler()
                return
            }
            
            self.fetchRecentHeartRate { sample in
                guard let sample = sample else {
                    completionHandler()
                    return
                }
                let heartRate = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
                print("heart rate from watch")
                print(heartRate);
                if let minHeartRate = Double(self.userDetails?.minHeartRate ?? ""),
                   let maxHeartRate = Double(self.userDetails?.maxHeartRate ?? "") {
                    print(minHeartRate, maxHeartRate);
                    if heartRate < minHeartRate || heartRate > maxHeartRate {
                        print("heart rate from database")
                        print(minHeartRate, maxHeartRate);
                    self.scheduleNotification(heartRate: heartRate)
                }
            }
            }
            completionHandler()
        }
        
        healthStore.execute(query)
        
       
        healthStore.enableBackgroundDelivery(for: heartRateType, frequency: .immediate) { success, error in
            if !success {
       
            }
        }
    }

    
    private func fetchRecentHeartRate(completion: @escaping (HKQuantitySample?) -> Void) {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            completion(nil)
            return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date(), options: .strictEndDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: heartRateType, predicate: predicate, limit: 1, sortDescriptors: [sortDescriptor]) { _, results, _ in
            DispatchQueue.main.async {
                completion(results?.first as? HKQuantitySample)
            }
        }
        
        healthStore.execute(query)
    }
    
    private func scheduleNotification(heartRate: Double) {
        let content = UNMutableNotificationContent()
        content.title = "Heart Rate Alert"
        content.body = "Do you need any help?"
        content.sound = .default
        content.categoryIdentifier = "HEART_RATE_ALERT"
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil) // Trigger immediately
        UNUserNotificationCenter.current().add(request)
    }

}
