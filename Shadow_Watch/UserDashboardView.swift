import SwiftUI
import HealthKit

struct UserDashboardView: View {
    @ObservedObject var viewModel = UserViewModel()
    @State private var startDate = Date().addingTimeInterval(-86400) // Default start date: 1 day ago
    @State private var endDate = Date() // Default end date: today
    @State private var heartRates: [HKQuantitySample] = []
    
    var body: some View {
        NavigationView {
            VStack {
                if let userDetails = viewModel.userDetails {
                    navigationIconsSection()
                } else {
                    Text("Loading user details...")
                        .onAppear {
                            viewModel.fetchUserDetails()
                        }
                }
            }
            .navigationTitle("Dashboard")
        }
    }
    
    private func navigationIconsSection() -> some View {
        HStack {
            NavigationLink(destination: userInfoSection(userDetails: viewModel.userDetails!)) {
                Image(systemName: "person.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)
                    .padding()
            }
            
            NavigationLink(destination: HeartRateDetailsView(startDate: $startDate, endDate: $endDate, heartRates: $heartRates, fetchHeartRates: fetchHeartRates)) {
                Image(systemName: "heart.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.red)
                    .padding()
            }
        }
    }

    private func userInfoSection(userDetails: UserModel) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Welcome, \(userDetails.firstName) \(userDetails.lastName)")
                .font(.title)
                .fontWeight(.bold)
            
            Divider()
            
            Group {
                HStack {
                    Text("Username:")
                        .fontWeight(.semibold)
                    Spacer()
                    Text(userDetails.username)
                }
                
                HStack {
                    Text("Sex:")
                        .fontWeight(.semibold)
                    Spacer()
                    Text(userDetails.sex)
                }
                
                HStack {
                    Text("Age:")
                        .fontWeight(.semibold)
                    Spacer()
                    Text("\(userDetails.age)")
                }
                
                HStack {
                    Text("Heart Rate:")
                        .fontWeight(.semibold)
                    Spacer()
                    Text("\(userDetails.minHeartRate) - \(userDetails.maxHeartRate) BPM")
                }
                
                HStack {
                    Text("Contact:")
                        .fontWeight(.semibold)
                    Spacer()
                    Text(userDetails.contactNumber)
                }
            }
            .font(.body)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white).shadow(radius: 5))
        .padding()
    }


 
    
    func fetchHeartRates() {
        print("Fetching heart rates...")
        HealthKitManager.shared.fetchHeartRates(from: startDate, to: endDate) { samples in
            DispatchQueue.main.async {
                if let samples = samples, !samples.isEmpty {
                    print("Fetched \(samples.count) samples \(startDate)")
                    self.heartRates = samples
                } else {
                    print("No samples were fetched \(startDate) end date \(endDate)")
                    self.heartRates = []
                }
            }
        }
    }
}


struct DateRangePicker: View {
    @Binding var startDate: Date
    @Binding var endDate: Date
    var onFetch: () -> Void

    var body: some View {
        NavigationView {
            Form {
                DatePicker("Start Date", selection: $startDate, in: ...endDate, displayedComponents: .date)
                DatePicker("End Date", selection: $endDate, in: startDate..., displayedComponents: .date)
                Button("Fetch Heart Rates", action: onFetch)
            }
            .navigationTitle("Select Date Range")
            .navigationBarItems(trailing: Button("Done", action: onFetch))
        }
    }
}


struct HeartRateDetailsView: View {
    @Binding var startDate: Date
    @Binding var endDate: Date
    @Binding var heartRates: [HKQuantitySample]
    var fetchHeartRates: () -> Void

    var body: some View {
        VStack {
            DateRangePicker(startDate: $startDate, endDate: $endDate) {
                self.fetchHeartRates()
            }
            
            // Assuming HeartRateGraphView exists and can display heartRates
            if !heartRates.isEmpty {
                HeartRateGraphView(heartRates: heartRates)
            } else {
                Text("No heart rate data available for the selected range.")
            }
        }
        .navigationTitle("Heart Rate Details")
    }
}
