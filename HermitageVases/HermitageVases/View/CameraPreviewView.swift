import SwiftUI
import AVFoundation

struct CameraPreviewView: UIViewRepresentable {
    let previewLayer: AVCaptureVideoPreviewLayer?

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .black
        // Здесь не добавляем слой сразу, он может быть ещё nil
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        /// Обновляет или добавляет previewLayer, когда он становится доступен
        uiView.layer.sublayers?.removeAll()
        if let layer = previewLayer {
            layer.frame = uiView.bounds
            uiView.layer.addSublayer(layer)
        }
    }
}
