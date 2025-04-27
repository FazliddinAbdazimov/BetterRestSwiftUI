import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    @State private var bedTimeResult = ""
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("When do you want to wake up?") {
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .datePickerStyle(WheelDatePickerStyle())
                }
                
                Section("Desired amount of sleep?") {
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                }
                
                Section("Daily coffee intake") {
                    Picker("^[\(coffeeAmount) cup](inflect: true)", selection: $coffeeAmount) {
                        ForEach(0..<21) {
                            Text("\($0)")
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section("Your ideal bedtime is...") {
                    Text("\(bedTimeResult)")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                }
            }
            .navigationTitle(Text("BetterRest"))
            .onAppear() {calculateBedtime()}
            .onChange(of: wakeUp) {calculateBedtime()}
            .onChange(of: sleepAmount) {calculateBedtime()}
            .onChange(of: coffeeAmount) {calculateBedtime()}
        }
    }
    
    func calculateBedtime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            bedTimeResult = sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            bedTimeResult = "Sorry, there was a problem calculating your bedtime. Please try again later."
        }
    }
}

#Preview {
    ContentView()
}
