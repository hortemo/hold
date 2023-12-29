import MessageUI
import SwiftUI

struct FeedbackView: UIViewControllerRepresentable {
  @Environment(\.presentationMode) var presentation

  func makeUIViewController(context: UIViewControllerRepresentableContext<FeedbackView>)
    -> MFMailComposeViewController
  {
    let vc = MFMailComposeViewController()
    vc.mailComposeDelegate = context.coordinator
    vc.setToRecipients(["hold@hortemo.com"])
    vc.setSubject("Feedback")
    return vc
  }

  func updateUIViewController(
    _ uiViewController: MFMailComposeViewController,
    context: UIViewControllerRepresentableContext<FeedbackView>
  ) {}

  func makeCoordinator() -> Coordinator {
    return Coordinator(self)
  }

  class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
    var parent: FeedbackView

    init(_ parent: FeedbackView) {
      self.parent = parent
    }

    func mailComposeController(
      _ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult,
      error: Error?
    ) {
      parent.presentation.wrappedValue.dismiss()
    }
  }
}
