import SwiftUI

struct ContentView: View {
    
    @State var pattyCount = 0
    @State var lastCheckInDate: Date? = nil
    @State var checkedDates: [Date] = []
    @State var burgers: [Burger] = []
    @State private var showSplash = true
    @State var startDate: Date? = nil
    
    var body: some View {
        
        if showSplash {
            SplashView {
                showSplash = false
            }
        } else {
            TabView {
                
                MainView(
                    pattyCount: $pattyCount,
                    lastCheckInDate: $lastCheckInDate,
                    checkedDates: $checkedDates,
                    burgers: $burgers
                )
                .tabItem {
                    Label("ホーム", systemImage: "house")
                }
                
                CalendarView(checkedDates: checkedDates)
                    .tabItem {
                        Label("カレンダー", systemImage: "calendar")
                    }
                
                HistoryView(burgers: burgers)
                    .tabItem {
                        Label("履歴", systemImage: "list.bullet")
                    }
            }
            .onAppear {
                loadData()
                loadBurgers()
            }
        }
    }
    
    func loadData() {
        pattyCount = UserDefaults.standard.integer(forKey: "pattyCount")
        
        if let date = UserDefaults.standard.object(forKey: "lastCheckInDate") as? Date {
            lastCheckInDate = date
        }
        
        if let dates = UserDefaults.standard.array(forKey: "checkedDates") as? [Date] {
            checkedDates = dates
        }
        
        if let start = UserDefaults.standard.object(forKey: "startDate") as? Date {
                startDate = start // ←追加（Bindingで渡す必要あり）
            }
    }
    
    func saveBurgers() {
        if let data = try? JSONEncoder().encode(burgers) {
            UserDefaults.standard.set(data, forKey: "burgers")
        }
    }
    
    func loadBurgers() {
        if let data = UserDefaults.standard.data(forKey: "burgers"),
           let decoded = try? JSONDecoder().decode([Burger].self, from: data) {
            burgers = decoded
        }
    }
}

#Preview {
    ContentView()
}
