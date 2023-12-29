import SwiftUI

struct DurationPicker: UIViewRepresentable {
  @Binding var selection: TimeInterval

  func makeUIView(context: Context) -> UIDatePicker {
    let datePicker = UIDatePicker()
    datePicker.datePickerMode = .countDownTimer
    datePicker.addTarget(
      context.coordinator,
      action: #selector(Coordinator.updateDuration),
      for: .valueChanged)
    return datePicker
  }

  func updateUIView(_ datePicker: UIDatePicker, context: Context) {
    datePicker.countDownDuration = selection
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  class Coordinator: NSObject {
    let parent: DurationPicker

    init(_ parent: DurationPicker) {
      self.parent = parent
    }

    @MainActor @objc func updateDuration(datePicker: UIDatePicker) {
      parent.selection = datePicker.countDownDuration
    }
  }
}

#Preview{
  @State var duration = TimeInterval(.hours(2) + .minutes(30))
  return DurationPicker(selection: $duration)
}
