import SwiftUI
import AVFoundation
import Vision

// MARK: - Notification Name

extension Notification.Name {
    
    /// Имя уведомления об обновлении списка обнаруженных объектов
    static let detectedObjectsUpdated = Notification.Name("detectedObjectsUpdated")
}

class CameraManager: NSObject, ObservableObject {
    /// Слой превью видеопотока камеры
    @Published var previewLayer: AVCaptureVideoPreviewLayer?
    
    /// Массив обнаруженных объектов
    @Published var detectedObjects: [DetectedObject] = []

    /// Сессия захвата видео
    private let session = AVCaptureSession()
    
    /// Выходной поток видеоданных
    private let videoOutput = AVCaptureVideoDataOutput()
    
    /// Очередь для обработки кадров камеры
    private let queue = DispatchQueue(label: "camera-queue")
    
    /// Обработчик детекции объектов
    private let objectDetector = ObjectDetector()

    override init() {
        super.init()
        
        /// Подписывает на уведомление об обновлении обнаруженных объектов
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateDetectedObjects(_:)),
            name: .detectedObjectsUpdated,
            object: nil
        )
    }

    /// Настраивает сессию камеры и запускает захват видео
    func setupCamera() {
        guard
            let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
            let input = try? AVCaptureDeviceInput(device: device)
        else { return }

        /// Начало конфигурации сессии
        session.beginConfiguration()
        
        /// Выставлен в high для более лучшего качества
        session.sessionPreset = .high
        
        /// Добавляет инпут камеры, если возможно
        if session.canAddInput(input) { session.addInput(input) }
        
        /// Добавляет выход видеоданных и делегат обработки
        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
            videoOutput.setSampleBufferDelegate(self, queue: queue)
        }
        
        /// Применяет конфигурацию сессии
        session.commitConfiguration()

        /// Создает превью слой для отображения видео
        let layer = AVCaptureVideoPreviewLayer(session: session)
        
        /// Устанавливает режим масштабирования видео
        layer.videoGravity = .resizeAspectFill
        
        /// Назначает слой для отображения на главном потоке
        DispatchQueue.main.async {
            self.previewLayer = layer
        }

        /// Запускает сессию в фоновом потоке
        queue.async {
            self.session.startRunning()
        }
    }

    /// Обновляет массив обнаруженных объектов из уведомления
    @objc private func updateDetectedObjects(_ notification: Notification) {
        
        /// Получает объект из уведомления как массив DetectedObject
        guard let objects = notification.object as? [DetectedObject] else { return }
        
        /// Обновляет свойство на главном потоке
        DispatchQueue.main.async {
            self.detectedObjects = objects
        }
    }
}

// MARK: - Camera Output Delegate

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    /// Обрабатывает выходной видеокадр для детекции объектов
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        /// Извлекаеn буфер изображения из sampleBuffer
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        /// Запускает детекцию объектов
        objectDetector.detectObjects(in: pixelBuffer)
    }
}
