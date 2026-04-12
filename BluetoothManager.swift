import Foundation
import CoreBluetooth
import Combine

class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate {
    
    @Published var rssi: Int = -100
    @Published var devices: [CBPeripheral] = []
    @Published var selectedPeripheral: CBPeripheral?
    
//    @Published var stableStartTime: Date? = nil
    let threshold = -65
    
//    @Published var accumulatedTime: Double = 0
    var lastUpdateTime = Date()
    
    var centralManager: CBCentralManager!
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    var savedUUID: UUID? {
        if let uuidString = UserDefaults.standard.string(forKey: "savedDevice") {
            return UUID(uuidString: uuidString)
        }
        return nil
    }
    
//    var stableProgress: Double {
//        guard let start = stableStartTime, rssi > threshold else {
//            return 0
//        }
//        
//        let elapsed = Date().timeIntervalSince(start)
//        return min(elapsed / 3.0, 1.0)
//    }
    
//    func isStable() -> Bool {
//        guard rssi > threshold else {
//            stableStartTime = nil
//            return false
//        }
//        
//        if stableStartTime == nil {
//            stableStartTime = Date()
//        }
//        
//        return Date().timeIntervalSince(stableStartTime!) > 3
//    }

//    private func updateStability(with rssi: Int) {
//        if rssi > threshold {
//            if stableStartTime == nil {
//                stableStartTime = Date()
//            }
//        } else {
//            stableStartTime = nil
//        }
//    }
    
    // 状態確認
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            centralManager.scanForPeripherals(
                withServices: nil,
                options: [CBCentralManagerScanOptionAllowDuplicatesKey: true]
            )
        } else {
            print("Bluetooth使えません")
        }
    }
    
    // デバイス検出
    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {
        
        DispatchQueue.main.async {
            
            // 重複防止
            if !self.devices.contains(where: { $0.identifier == peripheral.identifier }) {
                self.devices.append(peripheral)
            }
            
            if let saved = self.savedUUID,
               peripheral.identifier == saved {
                self.selectedPeripheral = peripheral
            }
            
            // 選択されたデバイスだけRSSI更新
            let now = Date()
            let delta = now.timeIntervalSince(self.lastUpdateTime)
            self.lastUpdateTime = now

            if peripheral.identifier == self.selectedPeripheral?.identifier {
                
                let currentRSSI = RSSI.intValue
                
                // 👇これ追加（超重要）
                self.rssi = currentRSSI
                
                // 安定判定更新（使うなら）
//                self.updateStability(with: currentRSSI)
                
                // 累積時間
//                if currentRSSI > self.threshold {
//                    self.accumulatedTime += delta
//                }
            }
        }
    }
    
//    func isAccumulatedStable() -> Bool {
//        return accumulatedTime >= 3.0
//    }
}
