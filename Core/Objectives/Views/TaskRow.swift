import SwiftUI

struct CustomProgressBar: View {
    let progress: Float
    let gradient: LinearGradient

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 8)

                Rectangle()
                    .fill(gradient)
                    .frame(
                        width: max(0, min(geometry.size.width * CGFloat(progress), geometry.size.width)), // Clamp the width
                        height: 8
                    )
                    .cornerRadius(4)
                    .shadow(
                        color: Color.white.opacity(0.6), // Glow color
                        radius: 10, // Glow radius
                        x: 0, // Horizontal offset
                        y: 0  // Vertical offset
                    )
                    .animation(.linear, value: progress)
            }
            .cornerRadius(4)
        }
        .frame(height: 8)
    }
}

struct TaskRow: View {
    @Binding var task: CustomTask
    let categoryGradient: LinearGradient
    let editAction: () -> Void

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    // Check if task is complete
                    let isComplete = task.progress == task.goal
                    let textColor = isComplete ? Color.green.opacity(0.7) : Color.gray

                    HStack {
                        Text(task.title)
                            .font(.subheadline)
                            .foregroundColor(.white)
                        
                        if isComplete {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Color.green.opacity(0.7))
                        }
                    }

                    Spacer()

                    if task.isAutoTrackEnabled {
                        Text("Auto-Tracking")
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .foregroundColor(.gray)
                            .padding(.trailing, 5)
                    }

                    Text("\(task.progress)/\(task.goal)")
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundColor(textColor)

                    Button(action: {
                        editAction()
                    }) {
                        Image(systemName: "pencil.circle")
                            .foregroundColor(.white)
                    }
                    .padding(.leading, 10)
                }

                // Safe progress calculation to avoid division by zero
                CustomProgressBar(
                    progress: task.goal > 0 ? Float(task.progress) / Float(task.goal) : 0,
                    gradient: categoryGradient
                )
            }
            .padding()
            .background(Color(red: 15/255, green: 15/255, blue: 15/255))
            .onTapGesture {
                editAction()
            }
        }
        .padding(.horizontal, 0)
    }
}

struct TaskRow_Previews: PreviewProvider {
    static var previews: some View {
        TaskRow(
            task: .constant(CustomTask(title: "Sample Task", progress: 5, goal: 5, isAutoTrackEnabled: true)),
            categoryGradient: LinearGradient(
                gradient: Gradient(colors: [Color.orange, Color.red]),
                startPoint: .leading,
                endPoint: .trailing
            ),
            editAction: {}
        )
    }
}
