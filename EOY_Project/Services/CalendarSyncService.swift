import EventKit
import FirebaseFirestore

struct CalendarSyncService {
    private let eventStore = EKEventStore()
    private let taskRepository = TaskRepository()
    private let userRepository = UserRepository()

    func sync(uid: String) async {
        guard EKEventStore.authorizationStatus(for: .event) == .fullAccess else {
            await clearStaleConnection(uid: uid)
            return
        }
        guard let existingTasks = try? await taskRepository.fetchTasks(uid: uid) else { return }

        let events = fetchUpcomingEvents()
        let calendarTasks = Dictionary(uniqueKeysWithValues:
            existingTasks.compactMap { task in task.calendarEventID.map { ($0, task) } })
        let eventIDs = Set(events.map(\.eventIdentifier))

        for event in events {
            if var task = calendarTasks[event.eventIdentifier] {
                guard task.title != event.title || task.dueDate?.dateValue() != event.startDate else { continue }
                task.title = event.title ?? task.title
                task.dueDate = Timestamp(date: event.startDate)
                try? await taskRepository.updateTask(uid: uid, task: task)
            } else {
                let task = TaskItem(
                    title: event.title ?? "Untitled event",
                    dueDate: Timestamp(date: event.startDate),
                    priority: "medium",
                    pointsAwarded: 20,
                    source: "calendar",
                    calendarEventID: event.eventIdentifier
                )
                try? await taskRepository.addTask(uid: uid, task: task)
            }
        }

        for (eventID, task) in calendarTasks where !eventIDs.contains(eventID) {
            if let id = task.id { try? await taskRepository.deleteTask(uid: uid, taskId: id) }
        }
    }

    private func clearStaleConnection(uid: String) async {
        guard var connections = (try? await userRepository.fetchProfile(uid: uid))?.connections,
              connections.calendarConnected else { return }
        connections.calendarConnected = false
        connections.calendarProvider = nil
        try? await userRepository.updateConnections(uid: uid, connections: connections)
    }

    private func fetchUpcomingEvents() -> [EKEvent] {
        let calendar = Calendar.current
        let start = calendar.date(byAdding: .day, value: -1, to: Date())!
        let end = calendar.date(byAdding: .day, value: 365, to: Date())!
        let predicate = eventStore.predicateForEvents(withStart: start, end: end, calendars: nil)
        return eventStore.events(matching: predicate)
    }
}
