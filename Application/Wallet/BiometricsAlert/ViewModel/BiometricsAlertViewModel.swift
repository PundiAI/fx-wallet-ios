import UIKit
extension BiometricsAlertViewController {
    class ViewModel {
        init(title: String, subTitle: String, leftBTitle: String, rightBTitle: String) {
            self.title = title
            self.subTitle = subTitle
            self.leftBTitle = leftBTitle
            self.rightBTitle = rightBTitle
            bind()
        }

        let title: String
        let subTitle: String
        let leftBTitle: String
        let rightBTitle: String
        private func bind() {}
    }
}
