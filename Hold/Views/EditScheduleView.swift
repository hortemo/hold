import FamilyControls
import ManagedSettings
import SwiftData
import SwiftUI

struct EditScheduleView: View {
  @ObservedObject var viewModel: ScheduleViewModel
  
  var body: some View {
    Section {
      if viewModel.type == .weeklyRecurring {
        Toggle("All day", isOn: $viewModel.allDay)
        if !viewModel.allDay {
          DatePicker("Start", selection: $viewModel.start, displayedComponents: [.hourAndMinute])
          DatePicker("End", selection: $viewModel.end, displayedComponents: [.hourAndMinute])
        }
        WeekdayPicker(selection: $viewModel.weekdays)
      } else if viewModel.type == .oneTime {
        DatePicker(
          "Start", selection: $viewModel.start, displayedComponents: [.date, .hourAndMinute])
        DatePicker("End", selection: $viewModel.end, displayedComponents: [.date, .hourAndMinute])
      } else if viewModel.type == .duration {
        DurationPicker(selection: $viewModel.duration)
      }
    } header: {
      HStack {
        Text("Schedule")
        Spacer()
        Picker("Type", selection: $viewModel.type) {
          Text("Now").tag(ScheduleViewModel.ScheduleType.duration)
          Text("One-time").tag(ScheduleViewModel.ScheduleType.oneTime)
          Text("Recurring").tag(ScheduleViewModel.ScheduleType.weeklyRecurring)
        }.textCase(nil)
      }
    }
  }
}

#Preview{
  Form {
    EditScheduleView(viewModel: ScheduleViewModel())
  }
}
