import SwiftUI
import AVFoundation
import Vision

struct ContentView: View {
    @StateObject private var cameraManager = CameraManager()
    
    @State private var selectedObj: DetectedObject?
    @State private var showModal = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                CameraPreviewView(previewLayer: cameraManager.previewLayer)
                    .edgesIgnoringSafeArea(.all)
                    /// Позволяет не ловить нажатия на область камеры
                    .allowsHitTesting(false)
                
                ForEach(cameraManager.detectedObjects) { obj in
                    BoundingBoxView(object: obj, parentSize: geo.size)
                        .onTapGesture  {
                            selectedObj = obj
                            showModal = true
                        }
                }
            }
            /// Открывает модальное окно
            .sheet(isPresented: $showModal) {
                if let selectedObj {
                    DetailView(selectedVase: selectedObj)
                }
            }
            /// Сетапит камеру при открытии
            .onAppear {
                cameraManager.setupCamera()
            }
        }
    }
}
