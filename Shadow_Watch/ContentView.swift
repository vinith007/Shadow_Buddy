import SwiftUI

struct ContentView: View {
    @State private var isAuthenticated = false

    var body: some View {
        if isAuthenticated {
            UserDashboardView()
        } else {
            NavigationView {
                ZStack {
                   
                    LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                        .edgesIgnoringSafeArea(.all)
                    
                   
                    VStack(spacing: 20) {
                        Text("Shadow Watch")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Spacer().frame(height: 50)
                        
                       
                        NavigationLink(destination: LoginView(isAuthenticated: $isAuthenticated)) {
                            Text("Login")
                                .bold()
                                .frame(minWidth: 0, maxWidth: .infinity)
                   
                                .padding()
                                .foregroundColor(.white)
                                .background(LinearGradient(gradient: Gradient(colors: [Color.purple, Color.blue]), startPoint: .leading, endPoint: .trailing))
                                .cornerRadius(10)
                                .padding(.horizontal, 50)
                        }
                        
                        
                        NavigationLink(destination: SignupView(isAuthenticated: $isAuthenticated)) {
                            Text("Sign Up")
                                .bold()
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .padding()
                                .foregroundColor(.white)
                                .background(LinearGradient(gradient: Gradient(colors: [Color.purple, Color.blue]), startPoint: .leading, endPoint: .trailing))
                                .cornerRadius(10)
                                .padding(.horizontal, 50)
                        }
                    }
                    .padding(.top, 200)
                }
            }
            .navigationBarHidden(true)
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
