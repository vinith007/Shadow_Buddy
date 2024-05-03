import SwiftUI
import HealthKit

struct HeartRateGraphView: View {
    var heartRates: [HKQuantitySample]
    
    // Dynamically calculated padding and spacing based on view size
    private func dynamicTopPadding(_ height: CGFloat) -> CGFloat { height * 0.03 }
    private func dynamicBottomPadding(_ height: CGFloat) -> CGFloat { height * 0.1 }
    private func dynamicLeadingPadding(_ width: CGFloat) -> CGFloat { width * 0.1 }
    private func dynamicTrailingPadding(_ width: CGFloat) -> CGFloat { width * 0.05 }

    //to normalize values to fit within the graph area, adjusted for dynamic padding
    private func normalize(_ value: Double, min: Double, max: Double, height: CGFloat, topPadding: CGFloat, bottomPadding: CGFloat) -> CGFloat {
        let normalizedValue = (value - min) / (max - min)
        return (1 - normalizedValue) * (height - topPadding - bottomPadding) + topPadding
    }

    //to format the date for display on the x-axis
    private func formattedDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss" // Example format: 12:00:00
        return dateFormatter.string(from: date)
    }

    // Computed property to generate y-axis labels
    private var yAxisLabels: [Double] {
        guard let maxHeartRate = heartRates.map({ $0.quantity.doubleValue(for: .init(from: "count/min")) }).max() else {
            return []
        }
        let interval = (maxHeartRate / 4)
        return stride(from: 0, through: maxHeartRate, by: interval).map { $0 }
    }

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            
            // Adjusting padding based on the view size
            let topPadding = dynamicTopPadding(height)
            let bottomPadding = dynamicBottomPadding(height)
            let leadingPadding = dynamicLeadingPadding(width)
            let trailingPadding = dynamicTrailingPadding(width)

            // Extracting heart rate values and corresponding dates
            let heartRateValues = heartRates.map { $0.quantity.doubleValue(for: .init(from: "count/min")) }
            let dates = heartRates.map { $0.startDate }

            // Finding min and max heart rates
            let minHeartRate = heartRateValues.min() ?? 0
            let maxHeartRate = heartRateValues.max() ?? 100
            
            // Creating path for the graph
            Path { path in
                for index in heartRateValues.indices {
                    let xPosition = (width - leadingPadding - trailingPadding) / CGFloat(heartRateValues.count - 1) * CGFloat(index) + leadingPadding
                    let yPosition = normalize(heartRateValues[index], min: minHeartRate, max: maxHeartRate, height: height, topPadding: topPadding, bottomPadding: bottomPadding)
                    
                    if index == 0 {
                        path.move(to: CGPoint(x: xPosition, y: yPosition))
                    } else {
                        path.addLine(to: CGPoint(x: xPosition, y: yPosition))
                    }
                }
            }
            .stroke(Color.blue, lineWidth: 2)
            .padding([.top, .bottom], topPadding)
            
            // Drawing the X-axis labels
            ForEach(0..<dates.count, id: \.self) { index in
                if index % (dates.count / 4) == 0 {
                    let xPosition = (width - leadingPadding - trailingPadding) / CGFloat(dates.count - 1) * CGFloat(index) + leadingPadding
                    let date = formattedDate(dates[index])
                    Text(date)
                        .font(.caption)
                        .rotationEffect(.degrees(-45))
                        .offset(x: xPosition, y: height - bottomPadding / 2) // Adjusted for dynamic padding
                        .foregroundColor(.gray)
                }
            }
            
            // Drawing the Y-axis labels
            ForEach(yAxisLabels, id: \.self) { label in
                let yPosition = normalize(label, min: minHeartRate, max: maxHeartRate, height: height, topPadding: topPadding, bottomPadding: bottomPadding)
                Text("\(Int(label)) BPM")
                    .font(.caption)
                    .position(x: leadingPadding / 2, y: yPosition)
                    .foregroundColor(.gray)
            }
        }
    }
}


//code for table
//import SwiftUI
//import HealthKit
//
//struct HeartRateGraphView: View {
//    var heartRates: [HKQuantitySample]
//
//    var body: some View {
//        List(heartRates, id: \.uuid) { sample in
//            HStack {
//                Text(sample.startDate, style: .time)
//                Spacer()
//                Text("\(sample.quantity.doubleValue(for: .init(from: "count/min"))) BPM")
//            }
//        }
//    }
//}
