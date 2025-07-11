import SwiftUI

struct AnalysisView: UIViewControllerRepresentable {
    let direction: Direction

    func makeUIViewController(context: Context) -> AnalysisViewController {
        let vc = AnalysisViewController()
        vc.direction = direction
        return vc
    }

    func updateUIViewController(_ uiViewController: AnalysisViewController, context: Context) {

    }
}

#Preview("income") {
    AnalysisView(direction: .income)
}

#Preview("outcome") {
    AnalysisView(direction: .outcome)
}
