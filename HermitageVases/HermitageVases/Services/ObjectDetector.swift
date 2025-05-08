import SwiftUI
import AVFoundation
import Vision

/// Менеджер детекции объектов на основе Core ML и Vision
class ObjectDetector {
    
    /// Массив запросов VNRequest для детекции объектов
    private var requests: [VNRequest] = []
    
    /// Очередь для фоновой обработки изображений
    private let processingQueue = DispatchQueue(
        label: "processing-queue",
        qos: .userInitiated
    )

    init() {
        setupVision()
    }

    /// Настраивает Core ML модель и формирует запросы Vision
    private func setupVision() {
        
        /// Загружает модель VasesML для Core ML
        let model = VasesML().model
        
        /// Пытается создать VNCoreMLModel, в случае ошибки выводит сообщение
        guard let visionModel = try? VNCoreMLModel(for: model) else {
            print("Failed to load VNCoreMLModel")
            return
        }
        
        /// Создает VNCoreMLRequest с обработчиком результатов
        let request = VNCoreMLRequest(model: visionModel) { request, error in
            
            /// Извлекает результаты распознавания и передает в обработку
            guard
                let results = request.results as? [VNRecognizedObjectObservation]
            else { return }
            self.process(results: results)
        }
        
        /// Устанавливает режим масштабирования изображения для запроса
        request.imageCropAndScaleOption = .scaleFill
        
        /// Присваивает массив запросов для выполнения
        requests = [request]
    }

    /// Запускает детекцию объектов в переданном буфере изображения
    func detectObjects(in pixelBuffer: CVPixelBuffer) {
        
        /// Отправляет выполнение запросов Vision в фоновую очередь
        processingQueue.async {
            
            /// Создает обработчик изображений для Vision
            let handler = VNImageRequestHandler(
                cvPixelBuffer: pixelBuffer,
                orientation: .right,
                options: [:]
            )
            do {
                /// Выполняет подготовленные запросы Vision
                try handler.perform(self.requests)
            } catch {
                print("Detection error: \(error)")
            }
        }
    }

    /// Обрабатывает результаты детекции и отбирает объекты с достаточной уверенностью
    private func process(results: [VNRecognizedObjectObservation]) {
        
        /// Преобразует результаты в массив DetectedObject, фильтруя по confidence
        let objects: [DetectedObject] = results.compactMap { obs in
            guard let top = obs.labels.first, top.confidence > 0.85 else { return nil }
            return DetectedObject(
                label: top.identifier,
                confidence: Double(top.confidence),
                boundingBox: obs.boundingBox
            )
        }
        
        /// Отправляет уведомление об обновлении обнаруженных объектов
        NotificationCenter.default.post(
            name: .detectedObjectsUpdated,
            object: objects
        )
    }
}
