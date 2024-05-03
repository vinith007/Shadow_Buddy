import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @Binding var isAuthenticated: Bool
    @State private var showingAlert = false
    @State private var alertMessage = ""

    var body: some View {
        ZStack {
            
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                Text("Login")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                TextField("Email", text: $email)
                    .padding()
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(10)
                    .padding(.horizontal, 30)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)

                SecureField("Password", text: $password)
                    .padding()
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(10)
                    .padding(.horizontal, 30)

                Button("Login") {
                    loginUser()
                }
                .bold()
                .frame(minWidth: 0, maxWidth: .infinity)
                .padding()
                .foregroundColor(.white)
                .background(LinearGradient(gradient: Gradient(colors: [Color.purple, Color.blue]), startPoint: .leading, endPoint: .trailing))
                .cornerRadius(10)
                .padding(.horizontal, 50)
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text("Login Failed"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
            }
        }
    }
    
    func loginUser() {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if authResult != nil {
                isAuthenticated = true
                HealthKitManager.shared.requestAuthorization { authorized, _ in
                    if authorized {
                        HealthKitManager.shared.startMonitoringHeartRate()
                    }
                }
            } else {
                alertMessage = error?.localizedDescription ?? "An unknown error occurred"
                showingAlert = true
            }
        }
    }
}
