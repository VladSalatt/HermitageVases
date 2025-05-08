import SwiftUI

struct BoundingBoxView: View {
    let object: DetectedObject
    let parentSize: CGSize

    var body: some View {
        
        /// Вычисление фрейма бокса относительно родительской вью
        let rect = object.boundingBox
        let width = rect.width * parentSize.width
        let height = rect.height * parentSize.height
        let x = rect.minX * parentSize.width + width / 2
        let y = (1 - rect.minY - rect.height) * parentSize.height + height / 2

        return ZStack(alignment: .topLeading) {
            Rectangle()
                /// Окрашивание цвета фрейма в цвет класса (для каждой из 4 ваз - свой цвет)
                .fill(object.boundingBoxColor.opacity(0.7))
                .frame(width: width, height: height)
                .position(x: x, y: y)

            Text(object.name)
                /// Установка шрифта
                .font(.caption2)
                /// Отступ
                .padding(4)
                /// Цвет заднего фона (такой же как и выше)
                .background(object.boundingBoxColor.opacity(0.6))
                /// Цвет текста
                .foregroundColor(.white)
                .position(x: x - width/2 + 60, y: y - height/2 + 10)
        }
    }
}
