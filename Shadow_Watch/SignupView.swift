import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct SignupView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var username = ""
    @State private var sex = ""
    @State private var age = ""
    @State private var minHeartRate = ""
    @State private var maxHeartRate = ""
    @State private var contactNumber = ""
    @Binding var isAuthenticated: Bool
    @State private var showingAlert = false
    @State private var alertMessage = "An error occurred"

    var body: some View {
        ZStack {
           
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)

            ScrollView {
                VStack(spacing: 20) {
                    Text("Sign Up")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()

                   
                    Group {
                        TextField("First Name", text: $firstName)
                        TextField("Last Name", text: $lastName)
                        TextField("Username", text: $username)
                        TextField("Sex", text: $sex)
                        TextField("Age", text: $age).keyboardType(.numberPad)
                        TextField("Minimum Heart Rate", text: $minHeartRate).keyboardType(.numberPad)
                        TextField("Maximum Heart Rate", text: $maxHeartRate).keyboardType(.numberPad)
                        TextField("Contact Number", text: $contactNumber).keyboardType(.phonePad)
                        TextField("Email", text: $email).keyboardType(.emailAddress)
                        SecureField("Password", text: $password)
                    }
                    .padding()
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(10)
                    .padding(.horizontal, 30)
                    .autocapitalization(.none)

                    
                    Button("Sign Up") {
                        createUserAndSaveDetails()
                    }
                    .bold()
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.white)
                    .background(LinearGradient(gradient: Gradient(colors: [Color.purple, Color.blue]), startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(10)
                    .padding(.horizontal, 50)
                    .alert(isPresented: $showingAlert) {
                        Alert(title: Text("Signup Failed"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                    }
                }
            }
        }
    }
    
    func createUserAndSaveDetails() {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let user = authResult?.user {
                self.isAuthenticated = true
                // Save additional user details in Firestore
                let db = Firestore.firestore()
                db.collection("users").document(user.uid).setData([
                    "firstName": firstName,
                    "lastName": lastName,
                    "username": username,
                    "sex": sex,
                    "age": age,
                    "minHeartRate": minHeartRate,
                    "maxHeartRate": maxHeartRate,
                    "contactNumber": contactNumber
                ]) { err in
                    if let err = err {
                        alertMessage = "Error writing document: \(err.localizedDescription)"
                        showingAlert = true
                    } else {
                        print("Document successfully written!")
                        // Implement a mechanism to navigate or dismiss the view upon successful signup
                    }
                }
            } else {
                alertMessage = error?.localizedDescription ?? "An unknown error occurred"
                showingAlert = true
            }
        }
    }
}
