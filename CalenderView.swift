import SwiftUI

struct CalendarView: View {
    
    var checkedDates: [Date]
    @State private var currentDate = Date()
    
    let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    
    func currentMonthTitle() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月"
        return formatter.string(from: currentDate)
    }
    
    var body: some View {
        VStack {
//            Text(currentMonthTitle())
//                .font(.title)
            
            HStack {
                Button(action: {
                    changeMonth(by: -1)
                }) {
                    Text("◀️")
                }
                
                Spacer()
                
                Text(currentMonthTitle())
                    .font(.title)
                
                Spacer()
                
                Button(action: {
                    changeMonth(by: 1)
                }) {
                    Text("▶️")
                }
            }
            
            // 曜日ヘッダー
            HStack {
                ForEach(["日","月","火","水","木","金","土"], id: \.self) { day in
                    Text(day)
                        .frame(maxWidth: .infinity)
                        .font(.caption)
                }
            }
            
            // 日付グリッド
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(Array(generateCalendarDates().enumerated()), id: \.offset) { index, date in 
                    
                    if let date = date {
                        ZStack {
                            
                            // 緑塗り（チェックイン）
                            if isChecked(date) {
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: 35, height: 35)
                            }
                            
                            // 赤枠（今日）
                            if Calendar.current.isDateInToday(date) {
                                Circle()
                                    .stroke(Color.red, lineWidth: 2)
                                    .frame(width: 35, height: 35)
                            }
                            
                            // 日付テキスト
                            Text(dayString(from: date))
                        }
                        .frame(width: 35, height: 35)
                    } else {
                        Text("")
                            .frame(width: 35, height: 35)
                    }
                }
            }
        }
        .padding()
        
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.width < -50 {
                        changeMonth(by: 1) // 左スワイプ → 次月
                    } else if value.translation.width > 50 {
                        changeMonth(by: -1) // 右スワイプ → 前月
                    }
                }
        )
    }
    
    func changeMonth(by value: Int) {
        if let newDate = Calendar.current.date(byAdding: .month, value: value, to: currentDate) {
            currentDate = newDate
        }
    }

    // カレンダー生成（曜日位置考慮）
    func generateCalendarDates() -> [Date?] {
        let calendar = Calendar.current
        let today = currentDate
        
        let range = calendar.range(of: .day, in: .month, for: today)!
        let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: today))!
        
        let weekday = calendar.component(.weekday, from: firstDay)
        
        var dates: [Date?] = []
        
        // 空白（曜日調整）
        for _ in 1..<weekday {
            dates.append(nil)
        }
        
        // 日付
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDay) {
                dates.append(date)
            }
        }
        
        return dates
    }
    
    func dayString(from date: Date) -> String {
        String(Calendar.current.component(.day, from: date))
    }
    
    func isChecked(_ date: Date) -> Bool {
        checkedDates.contains {
            Calendar.current.isDate($0, inSameDayAs: date)
        }
    }
}
