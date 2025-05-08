import SwiftUI

struct DetailView: View {
    let selectedVase: DetectedObject
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section  {
                    Image(selectedVase.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .clipShape(.rect(cornerRadius: 10))
                }
                
                Section  {
                    Text(selectedVase.placement)
                        .font(.headline)
                }
                
                Section {
                    Text(selectedVase.description)
                        .font(.body)
                }
            }
            .navigationTitle(selectedVase.name)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    DetailView(
        selectedVase: .init(
            label: "comos",
            confidence: 0.9,
            boundingBox: .init(x: 100, y: 100, width: 100, height: 100)
        )
    )
}
