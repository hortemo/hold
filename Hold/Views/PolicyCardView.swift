import SwiftUI

struct PolicyCardView: View {
  var viewModel: PolicyViewModel
  var showActivityGroup: Bool

  init(template: PolicyViewModel) {
    viewModel = template
    showActivityGroup = false
  }

  init(policy: Policy) {
    viewModel = PolicyViewModel(policy)
    showActivityGroup = true
  }

  var card: some View {
    HStack {
      VStack(alignment: .leading, spacing: 5) {
        Text(viewModel.name)
          .font(.headline)
        Text(viewModel.schedule.formatted())
          .font(.caption)
          .foregroundStyle(.secondary)
        if showActivityGroup {
          Text(viewModel.activityGroup.formatted())
            .font(.caption)
            .foregroundStyle(.secondary)
        }
      }
      Spacer()
    }
    .padding()
  }

  var body: some View {
    TimelineView(.periodic(from: .now, by: 1)) { timeline in
      let cornerRadius = 10.0
      if viewModel.isActive {
        card.background(Color.cyan.tertiary).cornerRadius(cornerRadius)
      } else if viewModel.isSnoozed {
        card.background(Color.purple.tertiary).cornerRadius(cornerRadius)
      } else {
        card.background(.regularMaterial).cornerRadius(cornerRadius)
      }
    }
  }
}

#Preview{
  PolicyCardView(
    policy: Policy(
      name: "🧘‍♀️ Zen hours",
      schedule: Schedule()
    )
  )
}
