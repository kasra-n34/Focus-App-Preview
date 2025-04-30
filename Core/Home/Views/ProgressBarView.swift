import Foundation
import SwiftUI

struct ProgressBarView: View {
    var label: String
    @Binding var progress: Float
    var color1: Color
    var color2: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(label)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.top, 5)
                Spacer()
            }
            .padding(.bottom, 4)

            HStack {
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .frame(width: 270, height: 20)
                        .foregroundColor(Color.gray.opacity(0.2))

                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .frame(width: 270 * CGFloat(progress), height: 20)
                        .background(
                            LinearGradient(gradient: Gradient(colors: [color1, color2]), startPoint: .leading, endPoint: .trailing)
                                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        )
                        .foregroundColor(.clear)
                        .shadow(color: color1.opacity(0.4), radius: 10, x: 0, y: 0)
                }
                Text("\(Int(progress * 100))%")
                    .fontWeight(.bold)
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .padding(.leading, 10)
            }
        }
        .padding(12)
        .background(Color.black)
        .cornerRadius(10)
        .shadow(color: Color.white.opacity(0.15), radius: 10, x: 0, y: 0)
    }
}

struct ProgressBarView_Previews: PreviewProvider {
    @State static var progress: Float = 0.6
    static var previews: some View {
        ProgressBarView(label: "Physicality", progress: $progress, color1: .orange, color2: .red)
            .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}
