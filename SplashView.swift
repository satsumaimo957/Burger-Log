import SwiftUI

struct SplashView: View {
    
    var onTap: () -> Void
    @State private var opacity = 1.0
    
    var body: some View {
        ZStack {
            
            // 背景
            Color.white
                .ignoresSafeArea()
            
            VStack {
                
                // 👤 製作者名（左上）
                HStack {
                    Text("by Shuto Sano")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                }
                .padding()
                
                Spacer()
                
                // 🍔 イラスト
                Image("burger") // ← まとめ画像でもOK
                    .resizable()
                    .scaledToFit()
                    .frame(height: 400)
                
                // 🏷 タイトル
                Text("Burger Log")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Spacer()
                
                // 👇 スタート案内
                Text("タップでスタート")
                    .opacity(opacity)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 1).repeatForever()) {
                            opacity = 0.3
                        }
                    }
            }
        }
        .onTapGesture {
            onTap()
        }
    }
}
