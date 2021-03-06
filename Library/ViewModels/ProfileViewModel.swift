import Foundation
import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public protocol ProfileViewModelInputs {
  /// Call when a project cell is tapped.
  func projectTapped(_ project: Project)

  /// Call when pull-to-refresh is invoked.
  func refresh()

  /// Call when settings is tapped.
  func settingsButtonTapped()

  /// Call when the project navigator has transitioned to a new project with its index.
  func transitionedToProject(at row: Int, outOf totalRows: Int)

  /// Call when the view will appear.
  func viewWillAppear(_ animated: Bool)

  /// Call when a new row is displayed.
  func willDisplayRow(_ row: Int, outOf totalRows: Int)
}

public protocol ProfileViewModelOutputs {
  /// Emits the user data that should be displayed.
  var user: Signal<User, Never> { get }

  /// Emits a list of backed projects that should be displayed.
  var backedProjects: Signal<[Project], Never> { get }

  /// Emits when the pull-to-refresh control is refreshing or not.
  var isRefreshing: Signal<Bool, Never> { get }

  /// Emits the project and ref tag when should go to project page.
  var goToProject: Signal<(Project, [Project], RefTag), Never> { get }

  /// Emits when settings should be shown.
  var goToSettings: Signal<Void, Never> { get }

  /// Emits when should scroll to the collection view item position.
  var scrollToProjectItem: Signal<Int, Never> { get }

  /// Emits a boolean that determines if the non-backer empty state is visible.
  var showEmptyState: Signal<Bool, Never> { get }
}

public protocol ProfileViewModelType {
  var inputs: ProfileViewModelInputs { get }
  var outputs: ProfileViewModelOutputs { get }
}

public final class ProfileViewModel: ProfileViewModelType, ProfileViewModelInputs, ProfileViewModelOutputs {
  public init() {
    let requestFirstPageWith = Signal.merge(
      self.viewWillAppearProperty.signal.filter(isFalse).ignoreValues(),
      self.refreshProperty.signal
    ).mapConst(
      DiscoveryParams.defaults
        |> DiscoveryParams.lens.backed .~ true
        |> DiscoveryParams.lens.sort .~ .endingSoon
    )

    let requestNextPageWhen = Signal.merge(
      self.willDisplayRowProperty.signal.skipNil(),
      self.transitionedToProjectRowAndTotalProperty.signal.skipNil()
    )
    .map { row, total in row >= total - 3 }
    .skipRepeats()
    .filter(isTrue)
    .ignoreValues()

    let isLoading: Signal<Bool, Never>
    (self.backedProjects, isLoading, _) = paginate(
      requestFirstPageWith: requestFirstPageWith,
      requestNextPageWhen: requestNextPageWhen,
      clearOnNewRequest: false,
      valuesFromEnvelope: { $0.projects },
      cursorFromEnvelope: { $0.urls.api.moreProjects },
      requestFromParams: { AppEnvironment.current.apiService.fetchDiscovery(params: $0) },
      requestFromCursor: { AppEnvironment.current.apiService.fetchDiscovery(paginationUrl: $0) }
    )

    self.isRefreshing = isLoading

    self.user = self.viewWillAppearProperty.signal
      .switchMap { _ in
        AppEnvironment.current.apiService.fetchUserSelf()
          .prefix(SignalProducer([AppEnvironment.current.currentUser].compact()))
          .demoteErrors()
      }

    self.showEmptyState = self.backedProjects.map { $0.isEmpty }

    self.goToSettings = self.settingsButtonTappedProperty.signal

    self.goToProject = self.backedProjects
      .takePairWhen(self.projectTappedProperty.signal.skipNil())
      .map { projects, project in (project, projects, RefTag.profileBacked) }

    self.scrollToProjectItem = self.transitionedToProjectRowAndTotalProperty.signal.skipNil().map(first)
  }

  fileprivate let projectTappedProperty = MutableProperty<Project?>(nil)
  public func projectTapped(_ project: Project) {
    self.projectTappedProperty.value = project
  }

  fileprivate let refreshProperty = MutableProperty(())
  public func refresh() {
    self.refreshProperty.value = ()
  }

  fileprivate let settingsButtonTappedProperty = MutableProperty(())
  public func settingsButtonTapped() {
    self.settingsButtonTappedProperty.value = ()
  }

  private let transitionedToProjectRowAndTotalProperty = MutableProperty<(row: Int, total: Int)?>(nil)
  public func transitionedToProject(at row: Int, outOf totalRows: Int) {
    self.transitionedToProjectRowAndTotalProperty.value = (row, totalRows)
  }

  fileprivate let viewWillAppearProperty = MutableProperty(false)
  public func viewWillAppear(_ animated: Bool) {
    self.viewWillAppearProperty.value = animated
  }

  fileprivate let willDisplayRowProperty = MutableProperty<(row: Int, total: Int)?>(nil)
  public func willDisplayRow(_ row: Int, outOf totalRows: Int) {
    self.willDisplayRowProperty.value = (row, totalRows)
  }

  public let user: Signal<User, Never>
  public let backedProjects: Signal<[Project], Never>
  public let isRefreshing: Signal<Bool, Never>
  public let goToProject: Signal<(Project, [Project], RefTag), Never>
  public let goToSettings: Signal<Void, Never>
  public let scrollToProjectItem: Signal<Int, Never>
  public let showEmptyState: Signal<Bool, Never>

  public var inputs: ProfileViewModelInputs { return self }
  public var outputs: ProfileViewModelOutputs { return self }
}
