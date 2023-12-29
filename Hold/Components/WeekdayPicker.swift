import SwiftUI

struct WeekdayPicker: View {
  @Binding var selection: [Int]
  
  let sortedWeekdays: [Int] = {
    let weekdays = [1, 2, 3, 4, 5, 6, 7]
    let firstWeekday = Calendar.current.firstWeekday
    return weekdays.filter { $0 >= firstWeekday } + weekdays.filter { $0 < firstWeekday }
  }()

  func label(for weekday: Int) -> String {
    Calendar.current.veryShortWeekdaySymbols[weekday - 1]
  }

  func isSelected(_ weekday: Int) -> Bool {
    selection.contains(weekday)
  }

  func toggle(_ weekday: Int) {
    if isSelected(weekday) {
      selection.removeAll { $0 == weekday }
    } else {
      selection.append(weekday)
    }
  }

  var body: some View {
    HStack {
      ForEach(sortedWeekdays, id: \.self) { weekday in
        let isSelected = self.isSelected(weekday)
        let label = self.label(for: weekday)

        ZStack {
          Circle()
            .aspectRatio(1.0, contentMode: .fit)
            .foregroundStyle(isSelected ? .blue : .gray)
          Text(label)
            .foregroundColor(isSelected ? .white : .black)
        }
        .onTapGesture {
          self.toggle(weekday)
        }
      }
    }
  }
}
