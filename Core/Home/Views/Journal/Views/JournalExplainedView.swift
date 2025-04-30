import SwiftUI

struct JournalExplainedView: View {
    @State private var currentValue: Int = 0
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack {
                    
                    Spacer()
                    
                    Text("Built-in Journals")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.bottom)
                        .multilineTextAlignment(.center)
                    
                    Text("Journaling made easy.")
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 350)
                        .foregroundColor(.white)
                        .padding(.bottom)
                        .padding(.bottom)
                    
                    HStack {
                        Spacer()
                        Image(systemName: "list.bullet.rectangle")
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .font(.system(size: 25))
                            .padding(.trailing)
                            
                        Spacer()
                        VStack {
                            Text("View your Journals")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding()
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: 250)
                            
                            Text("Tap on 'Journal Entries' in the homepage to view all your journal entries.")
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: 250)
                        }
                        .foregroundColor(.white)
                        Spacer()
                    }
                    Spacer()
                    HStack {
                        Spacer()
                        Image(systemName: "book.pages.fill")
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .font(.system(size: 25))
                            .padding(.trailing)
                            
                        Spacer()
                        VStack {
                            Text("Create a Journal")
                                .font(.title2)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                                .padding()
                                .frame(maxWidth: 250)
                            
                            Text("Tap the + within the journal entries list.")
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: 250)
                                
                        }
                        .foregroundColor(.white)
                        Spacer()
                    }
                    
                    Spacer()
                    
                    NavigationLink(destination: NewFieldModal(
                        value: $currentValue,
                        model: NewFieldModel(title: "Track Journaling", units: "Entries", API: "Focus", category: "Mindfulness"),
                        currentCategory: "Mindfulness",
                        completion: {_ in 
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    )) {
                        Text("Track Journaling")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black)
                            .cornerRadius(10)
                    }
                    .shadow(color: Color.white.opacity(1), radius: 4, x: 0, y: 0) // Glow effect
                    .padding()
                    
                    Spacer()
                }
            }
        }
    }
}

struct JournalExplainedView_Previews: PreviewProvider {
    static var previews: some View {
        JournalExplainedView()
    }
}
