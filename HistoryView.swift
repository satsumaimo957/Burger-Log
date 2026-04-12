import SwiftUI

struct HistoryView: View {
    
    var burgers: [Burger]
    
    var body: some View {
        ScrollView {
            ForEach(burgers) { burger in
                VStack {
                    
                    // 🍔 見た目再現
                    VStack {
                        VStack(spacing: -55) {
                            
                            // 上バンズ
                            Image("top_bun")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 75)
                                .zIndex(100)
                                .offset(y: -15)
                            
                            // パティ
                            ForEach(0..<burger.pattyCount, id: \.self) { index in
                                Image("patty")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 80)
                                    .zIndex(Double(burger.pattyCount - index))
                            }
                            
                            // 下バンズ
                            Image("bottom_bun")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 100)
                                .zIndex(-1)
                        }
                        
                        
                        // 📅 日付
                        Text("\(dateString(burger.startDate)) 〜 \(dateString(burger.endDate))")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    
                }
                .padding()
            }
        }
    }
    
    func dateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter.string(from: date)
    }
}
