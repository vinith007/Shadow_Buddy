import SwiftUI
import HealthKit

struct DateRangeSelectionView: View {
    @State private var startDate = Date().addingTimeInterval(-86400)
    @State private var endDate = Date() 
    @State private var heartRates: [HKQuantitySample] = []

    var body: some View {
        VStack {
            DatePicker("Start Date", selection: $startDate, in: ...Date(), displayedComponents: .date)
            DatePicker("End Date", selection: $endDate, in: ...Date(), displayedComponents: .date)
            
            Button("Fetch Heart Rates") {
                fetchHeartRates()
            }
            
            HeartRateGraphView(heartRates: heartRates)
        }
        .padding()
    }
    
    func fetchHeartRates() {
        HealthKitManager.shared.fetchHeartRates(from: startDate, to: endDate) { samples in
            if let samples = samples {
                self.heartRates = samples
            }
        }
    }
}
