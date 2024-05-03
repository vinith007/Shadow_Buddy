import Foundation
//import FirebaseFirestore
import Firebase

class UserViewModel: ObservableObject {
    @Published var userDetails: UserModel?
    
    func fetchUserDetails() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
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
            } else {
                print("Document does not exist")
            }
        }
    }
}
