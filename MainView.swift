import SwiftUI
import CoreBluetooth

struct MainView: View {
    
    @Binding var pattyCount: Int
    @Binding var lastCheckInDate: Date?
    @Binding var checkedDates: [Date]
    @State var fakeRSSI: Double = -80
    @StateObject var bluetoothManager = BluetoothManager()
    let threshold: Double = -50
    
    let maxPatty = 7
    let isDateRestrictionEnabled = false
    
    @State private var showDeviceList = false
    @State var isCompleted = false
    
    @State var startDate: Date? = nil
    @Binding var burgers: [Burger]
    
    var currentRSSI: Double {
        Double(bluetoothManager.rssi)
    }

    var rssiProgress: Double {
        let minRSSI = -100.0
        let maxRSSI = threshold
        let value = (Double(bluetoothManager.rssi) - minRSSI) / (maxRSSI - minRSSI)
        return min(max(value, 0), 1)
    }
    
    func isCheckedToday() -> Bool {
        guard let lastDate = lastCheckInDate else { return false }
        return Calendar.current.isDateInToday(lastDate)
    }
    
    func saveData() {
        UserDefaults.standard.set(pattyCount, forKey: "pattyCount")
        
        if let date = lastCheckInDate {
            UserDefaults.standard.set(date, forKey: "lastCheckInDate")
        }
        
        if let start = startDate {
                UserDefaults.standard.set(start, forKey: "startDate") // ←追加
            }
        
        UserDefaults.standard.set(checkedDates, forKey: "checkedDates")
    }
    
    func isInRange() -> Bool {
        return currentRSSI > threshold
    }
    
    func canCheckIn() -> Bool {
        if pattyCount >= maxPatty { return false }
        
        if isCompleted { return false } // ←追加
        
        if isDateRestrictionEnabled && isCheckedToday() { return false }
        
        if !isInRange() { return false }
        
        return true
    }
    
    func resetData() {
        pattyCount = 0
        lastCheckInDate = nil
        checkedDates = []
        isCompleted = false // ←追加
        burgers.removeAll()
        
        UserDefaults.standard.removeObject(forKey: "pattyCount")
        UserDefaults.standard.removeObject(forKey: "lastCheckInDate")
        UserDefaults.standard.removeObject(forKey: "checkedDates")
        UserDefaults.standard.removeObject(forKey: "burgers")
    }
    
    var body: some View {
        VStack {
            
            Button(action: {
                showDeviceList.toggle()
            }) {
                HStack {
                    Text("利用デバイス: \(bluetoothManager.selectedPeripheral?.name ?? "未選択")")
                    Spacer()
                    Text("▼")
                }
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
            }
            
            if showDeviceList {
                List(bluetoothManager.devices, id: \.identifier) { device in
                    Button(action: {
                        bluetoothManager.selectedPeripheral = device

                        UserDefaults.standard.set(
                            device.identifier.uuidString,
                            forKey: "savedDevice"
                        )
                        showDeviceList = false
                    }) {
                        Text(device.name ?? String(device.identifier.uuidString.prefix(6)))
                    }
                }
                .frame(height: 150)
            }
            
            Spacer()
            
            ZStack {
                
                // 🍔 ハンバーガー本体
                VStack(spacing: -55) {
                    Spacer()
                    
                    if isCompleted {
                        Image("top_bun")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 75)
                            .zIndex(100)
                            .offset(y: -15)
                    }
                    
                    ForEach(0..<pattyCount, id: \.self) { index in
                        Image("patty")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 80)
                            .zIndex(Double(pattyCount - index))
                    }
                    .animation(.easeInOut, value: pattyCount)
                    
                    Image("bottom_bun")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 100)
                        .zIndex(-1)
                }
                
                // 🎉 完成テキスト（オーバーレイ）
                if isCompleted {
                    Text("完成！🍔")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                        .transition(.opacity)
                        .zIndex(200)
                }
            }
            .frame(height: 300)
            .animation(.easeInOut, value: isCompleted)
            
//            Text("進捗: \(pattyCount)/\(maxPatty)")
            
            Spacer()
            
            ZStack(alignment: .leading) {
                
                // 背景
                RoundedRectangle(cornerRadius: 10)
                    .frame(height: 20)
                    .foregroundColor(Color.gray.opacity(0.3))
                
                // ゲージ
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: CGFloat(rssiProgress) * 300, height: 20)
                    .foregroundColor(
                        Color(
                            red: 1 - rssiProgress,
                            green: rssiProgress,
                            blue: 0
                        )
                    )
            }
            .padding()
            
//            ZStack(alignment: .leading) {
//                
//                RoundedRectangle(cornerRadius: 10)
//                    .frame(height: 20)
//                    .foregroundColor(Color.gray.opacity(0.3))
//                
//                RoundedRectangle(cornerRadius: 10)
//                    .frame(width: CGFloat(bluetoothManager.stableProgress) * 300, height: 20)
//                    .foregroundColor(
//                        bluetoothManager.stableProgress >= 1 ? .green : .orange
//                    )
//            }
//            .padding()
            
//            Text(
//                bluetoothManager.stableProgress >= 1
//                ? "チェックイン可能"
//                : "近づいてください"
//            )
            
            Button(action: {
                if pattyCount < maxPatty {
                    
                    if isDateRestrictionEnabled && isCheckedToday() {
                        return
                    }
                    
                    if startDate == nil {
                        startDate = Date()
                    }
                    
                    pattyCount += 1
                    lastCheckInDate = Date()
                    
                    let today = Date()
                    if !checkedDates.contains(where: {
                        Calendar.current.isDate($0, inSameDayAs: today)
                    }) {
                        checkedDates.append(today)
                    }
                    
//                    bluetoothManager.accumulatedTime = 0
//                    bluetoothManager.stableStartTime = nil
                    
                    saveData()
                }
            }) {
                Text("チェックイン")
                    .padding()
                    .background(canCheckIn() ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
//            .disabled(!canCheckIn() || !bluetoothManager.isAccumulatedStable())
            
            Button(action: {
                if pattyCount > 0 {
                    
                    let burger = Burger(
                        pattyCount: pattyCount,
                        startDate: startDate ?? Date(),
                        endDate: Date()
                    )
                    
                    burgers.append(burger)
                    
                    // 👇追加
                    if let data = try? JSONEncoder().encode(burgers) {
                        UserDefaults.standard.set(data, forKey: "burgers")
                    }
                    
                    isCompleted = true

                    // 👇 少し遅れてリセット（演出っぽくなる）
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        isCompleted = false
                        startDate = nil
                        pattyCount = 0
                    }
                    
                    startDate = nil
                    pattyCount = 0
                }
            }) {
                Text("完成する")
                    .padding()
                    .background(pattyCount > 0 ? Color.green : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(pattyCount == 0)
            
            Button(action: {
                resetData()
            }) {
                Text("リセット（開発用）")
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            Spacer()
        }
    }
}
