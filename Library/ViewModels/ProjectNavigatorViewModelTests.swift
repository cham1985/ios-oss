@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import UIKit
import XCTest

internal final class ProjectNavigatorViewModelTests: TestCase {
  fileprivate let vm: ProjectNavigatorViewModelType = ProjectNavigatorViewModel()

  fileprivate let cancelInteractiveTransition = TestObserver<(), Never>()
  fileprivate let dismissViewController = TestObserver<(), Never>()
  fileprivate let finishInteractiveTransition = TestObserver<(), Never>()
  private let notifyDelegateTransitionedToProjectIndex = TestObserver<Int, Never>()
  fileprivate let setInitialPagerViewController = TestObserver<(), Never>()
  fileprivate let setNeedsStatusBarAppearanceUpdate = TestObserver<(), Never>()
  fileprivate let setTransitionAnimatorIsInFlight = TestObserver<Bool, Never>()
  fileprivate let updateInteractiveTransition = TestObserver<CGFloat, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.cancelInteractiveTransition.observe(self.cancelInteractiveTransition.observer)
    self.vm.outputs.dismissViewController.observe(self.dismissViewController.observer)
    self.vm.outputs.finishInteractiveTransition.observe(self.finishInteractiveTransition.observer)
    self.vm.outputs.notifyDelegateTransitionedToProjectIndex
      .observe(self.notifyDelegateTransitionedToProjectIndex.observer)
    self.vm.outputs.setInitialPagerViewController.observe(self.setInitialPagerViewController.observer)
    self.vm.outputs.setNeedsStatusBarAppearanceUpdate.observe(self.setNeedsStatusBarAppearanceUpdate.observer)
    self.vm.outputs.setTransitionAnimatorIsInFlight.observe(self.setTransitionAnimatorIsInFlight.observer)
    self.vm.outputs.updateInteractiveTransition.observe(self.updateInteractiveTransition.observer)
  }

  func testTransitionLifecycle_ScrollDown_BackUp() {
    self.vm.inputs.configureWith(project: .template, refTag: .category)
    self.vm.inputs.viewDidLoad()

    self.cancelInteractiveTransition.assertValueCount(0)
    self.dismissViewController.assertValueCount(0)
    self.finishInteractiveTransition.assertValueCount(0)
    self.updateInteractiveTransition.assertValueCount(0)
    self.setTransitionAnimatorIsInFlight.assertValues([])

    self.vm.inputs.panning(
      contentOffset: CGPoint(x: 0, y: 20),
      translation: CGPoint(x: 0, y: -20),
      velocity: CGPoint(x: 0, y: -20),
      isDragging: true
    )

    self.cancelInteractiveTransition.assertValueCount(0)
    self.dismissViewController.assertValueCount(0)
    self.finishInteractiveTransition.assertValueCount(0)
    self.updateInteractiveTransition.assertValueCount(0)
    self.setTransitionAnimatorIsInFlight.assertValues([false])

    self.vm.inputs.panning(
      contentOffset: CGPoint(x: 0, y: 0),
      translation: CGPoint(x: 0, y: 0),
      velocity: CGPoint(x: 0, y: 20),
      isDragging: true
    )

    self.cancelInteractiveTransition.assertValueCount(0)
    self.dismissViewController.assertValueCount(0)
    self.finishInteractiveTransition.assertValueCount(0)
    self.updateInteractiveTransition.assertValueCount(0)
    self.setTransitionAnimatorIsInFlight.assertValues([false])

    self.vm.inputs.panning(
      contentOffset: CGPoint(x: 0, y: 0),
      translation: CGPoint(x: 0, y: 0),
      velocity: CGPoint(x: 0, y: 0),
      isDragging: false
    )

    self.cancelInteractiveTransition.assertValueCount(0)
    self.dismissViewController.assertValueCount(0)
    self.finishInteractiveTransition.assertValueCount(0)
    self.updateInteractiveTransition.assertValueCount(0)
    self.setTransitionAnimatorIsInFlight.assertValues([false])
  }

  func testTransitionLifecycle_ScrollDown_BackUp_Overscroll() {
    self.vm.inputs.configureWith(project: .template, refTag: .category)
    self.vm.inputs.viewDidLoad()

    self.cancelInteractiveTransition.assertValueCount(0)
    self.dismissViewController.assertValueCount(0)
    self.finishInteractiveTransition.assertValueCount(0)
    self.updateInteractiveTransition.assertValueCount(0)
    self.setTransitionAnimatorIsInFlight.assertValues([])

    self.vm.inputs.panning(
      contentOffset: CGPoint(x: 0, y: 20),
      translation: CGPoint(x: 0, y: -20),
      velocity: CGPoint(x: 0, y: -20),
      isDragging: true
    )

    self.cancelInteractiveTransition.assertValueCount(0)
    self.dismissViewController.assertValueCount(0)
    self.finishInteractiveTransition.assertValueCount(0)
    self.updateInteractiveTransition.assertValueCount(0)
    self.setTransitionAnimatorIsInFlight.assertValues([false])

    self.vm.inputs.panning(
      contentOffset: CGPoint(x: 0, y: 0),
      translation: CGPoint(x: 0, y: 0),
      velocity: CGPoint(x: 0, y: 20),
      isDragging: true
    )

    self.cancelInteractiveTransition.assertValueCount(0)
    self.dismissViewController.assertValueCount(0)
    self.finishInteractiveTransition.assertValueCount(0)
    self.updateInteractiveTransition.assertValueCount(0)
    self.setTransitionAnimatorIsInFlight.assertValues([false])

    self.vm.inputs.panning(
      contentOffset: CGPoint(x: 0, y: -20),
      translation: CGPoint(x: 0, y: 20),
      velocity: CGPoint(x: 0, y: 20),
      isDragging: true
    )

    self.cancelInteractiveTransition.assertValueCount(0)
    self.dismissViewController.assertValueCount(1)
    self.finishInteractiveTransition.assertValueCount(0)
    self.updateInteractiveTransition.assertValueCount(1)
    self.setTransitionAnimatorIsInFlight.assertValues([false, true])

    self.vm.inputs.panning(
      contentOffset: CGPoint(x: 0, y: -40),
      translation: CGPoint(x: 0, y: 40),
      velocity: CGPoint(x: 0, y: 20),
      isDragging: true
    )

    self.cancelInteractiveTransition.assertValueCount(0)
    self.dismissViewController.assertValueCount(1)
    self.finishInteractiveTransition.assertValueCount(0)
    self.updateInteractiveTransition.assertValueCount(2)
    self.setTransitionAnimatorIsInFlight.assertValues([false, true])

    self.vm.inputs.panning(
      contentOffset: CGPoint(x: 0, y: -40),
      translation: CGPoint(x: 0, y: 40),
      velocity: CGPoint(x: 0, y: 20),
      isDragging: false
    )

    self.cancelInteractiveTransition.assertValueCount(0)
    self.dismissViewController.assertValueCount(1)
    self.finishInteractiveTransition.assertValueCount(1)
    self.updateInteractiveTransition.assertValueCount(2)
    self.setTransitionAnimatorIsInFlight.assertValues([false, true, false])
  }

  func testTransitionLifecycle_Overscroll_Cancel() {
    self.vm.inputs.configureWith(project: .template, refTag: .category)
    self.vm.inputs.viewDidLoad()

    self.cancelInteractiveTransition.assertValueCount(0)
    self.dismissViewController.assertValueCount(0)
    self.finishInteractiveTransition.assertValueCount(0)
    self.updateInteractiveTransition.assertValueCount(0)
    self.setTransitionAnimatorIsInFlight.assertValues([])

    self.vm.inputs.panning(
      contentOffset: CGPoint(x: 0, y: -20),
      translation: CGPoint(x: 0, y: 20),
      velocity: CGPoint(x: 0, y: 20),
      isDragging: true
    )

    self.cancelInteractiveTransition.assertValueCount(0)
    self.dismissViewController.assertValueCount(1)
    self.finishInteractiveTransition.assertValueCount(0)
    self.updateInteractiveTransition.assertValueCount(1)
    self.setTransitionAnimatorIsInFlight.assertValues([true])

    self.vm.inputs.panning(
      contentOffset: CGPoint(x: 0, y: -10),
      translation: CGPoint(x: 0, y: 10),
      velocity: CGPoint(x: 0, y: -10),
      isDragging: true
    )

    self.cancelInteractiveTransition.assertValueCount(0)
    self.dismissViewController.assertValueCount(1)
    self.finishInteractiveTransition.assertValueCount(0)
    self.updateInteractiveTransition.assertValueCount(2)
    self.setTransitionAnimatorIsInFlight.assertValues([true])

    self.vm.inputs.panning(
      contentOffset: CGPoint(x: 0, y: -10),
      translation: CGPoint(x: 0, y: 10),
      velocity: CGPoint(x: 0, y: -10),
      isDragging: false
    )

    self.cancelInteractiveTransition.assertValueCount(1)
    self.dismissViewController.assertValueCount(1)
    self.finishInteractiveTransition.assertValueCount(0)
    self.updateInteractiveTransition.assertValueCount(2)
    self.setTransitionAnimatorIsInFlight.assertValues([true, false])
  }

  func testTransitionLifecycle_Overscroll_ScrollBack() {
    self.vm.inputs.configureWith(project: .template, refTag: .category)
    self.vm.inputs.viewDidLoad()

    self.cancelInteractiveTransition.assertValueCount(0)
    self.dismissViewController.assertValueCount(0)
    self.finishInteractiveTransition.assertValueCount(0)
    self.updateInteractiveTransition.assertValueCount(0)
    self.setTransitionAnimatorIsInFlight.assertValues([])

    self.vm.inputs.panning(
      contentOffset: CGPoint(x: 0, y: -20),
      translation: CGPoint(x: 0, y: 20),
      velocity: CGPoint(x: 0, y: 20),
      isDragging: true
    )

    self.cancelInteractiveTransition.assertValueCount(0)
    self.dismissViewController.assertValueCount(1)
    self.finishInteractiveTransition.assertValueCount(0)
    self.updateInteractiveTransition.assertValueCount(1)
    self.setTransitionAnimatorIsInFlight.assertValues([true])

    self.vm.inputs.panning(
      contentOffset: CGPoint(x: 0, y: 0),
      translation: CGPoint(x: 0, y: 20),
      velocity: CGPoint(x: 0, y: -20),
      isDragging: true
    )

    self.cancelInteractiveTransition.assertValueCount(0)
    self.dismissViewController.assertValueCount(1)
    self.finishInteractiveTransition.assertValueCount(0)
    self.updateInteractiveTransition.assertValueCount(2)
    self.setTransitionAnimatorIsInFlight.assertValues([true])

    self.vm.inputs.panning(
      contentOffset: CGPoint(x: 0, y: 20),
      translation: CGPoint(x: 0, y: -20),
      velocity: CGPoint(x: 0, y: -20),
      isDragging: true
    )

    self.cancelInteractiveTransition.assertValueCount(1)
    self.dismissViewController.assertValueCount(1)
    self.finishInteractiveTransition.assertValueCount(0)
    self.updateInteractiveTransition.assertValueCount(2)
    self.setTransitionAnimatorIsInFlight.assertValues([true, false])

    self.vm.inputs.panning(
      contentOffset: CGPoint(x: 0, y: 20),
      translation: CGPoint(x: 0, y: -20),
      velocity: CGPoint(x: 0, y: -20),
      isDragging: false
    )

    self.cancelInteractiveTransition.assertValueCount(1)
    self.dismissViewController.assertValueCount(1)
    self.finishInteractiveTransition.assertValueCount(0)
    self.updateInteractiveTransition.assertValueCount(2)
    self.setTransitionAnimatorIsInFlight.assertValues([true, false])
  }

  // This test exercises a particular bug experienced if you are not careful with the transition phases.
  // It does the following:
  //   - Pull down a bit to start dismissing
  //   - Scroll back up to precisely contentOffset=0 to cancel dismissal
  //   - Transition phase is in weird state where it cannot dismiss.
  func testTransitionLifecycle_Bug() {
    self.vm.inputs.configureWith(project: .template, refTag: .category)
    self.vm.inputs.viewDidLoad()

    self.cancelInteractiveTransition.assertValueCount(0)
    self.dismissViewController.assertValueCount(0)
    self.finishInteractiveTransition.assertValueCount(0)
    self.updateInteractiveTransition.assertValueCount(0)
    self.setTransitionAnimatorIsInFlight.assertValueCount(0)

    self.vm.inputs.panning(
      contentOffset: CGPoint(x: 0, y: -20),
      translation: CGPoint(x: 0, y: 20),
      velocity: CGPoint(x: 0, y: 20),
      isDragging: true
    )

    self.cancelInteractiveTransition.assertValueCount(0)
    self.dismissViewController.assertValueCount(1)
    self.finishInteractiveTransition.assertValueCount(0)
    self.updateInteractiveTransition.assertValueCount(1)
    self.setTransitionAnimatorIsInFlight.assertValues([true])

    self.vm.inputs.panning(
      contentOffset: CGPoint(x: 0, y: 0),
      translation: CGPoint(x: 0, y: 0),
      velocity: CGPoint(x: 0, y: -20),
      isDragging: true
    )

    self.cancelInteractiveTransition.assertValueCount(0)
    self.dismissViewController.assertValueCount(1)
    self.finishInteractiveTransition.assertValueCount(0)
    self.updateInteractiveTransition.assertValueCount(2)
    self.setTransitionAnimatorIsInFlight.assertValues([true])

    self.vm.inputs.panning(
      contentOffset: CGPoint(x: 0, y: 20),
      translation: CGPoint(x: 0, y: -20),
      velocity: CGPoint(x: 0, y: -20),
      isDragging: true
    )

    self.cancelInteractiveTransition.assertValueCount(1)
    self.dismissViewController.assertValueCount(1)
    self.finishInteractiveTransition.assertValueCount(0)
    self.updateInteractiveTransition.assertValueCount(2)
    self.setTransitionAnimatorIsInFlight.assertValues([true, false])

    self.vm.inputs.panning(
      contentOffset: CGPoint(x: 0, y: 20),
      translation: CGPoint(x: 0, y: -20),
      velocity: CGPoint(x: 0, y: 0),
      isDragging: false
    )

    self.cancelInteractiveTransition.assertValueCount(1)
    self.dismissViewController.assertValueCount(1)
    self.finishInteractiveTransition.assertValueCount(0)
    self.updateInteractiveTransition.assertValueCount(2)
    self.setTransitionAnimatorIsInFlight.assertValues([true, false])
  }

  func testSetNeedsStatusBarAppearanceUpdate() {
    let playlist = (0...4).map { idx in .template |> Project.lens.id .~ (idx + 42) }
    let project = playlist.first!

    self.vm.inputs.configureWith(project: project, refTag: .category)
    self.vm.inputs.viewDidLoad()

    self.setNeedsStatusBarAppearanceUpdate.assertValueCount(0)

    self.vm.inputs.willTransition(toProject: playlist[1], at: 1)

    self.setNeedsStatusBarAppearanceUpdate.assertValueCount(0)

    self.vm.inputs.pageTransition(completed: true, from: 0)

    self.setNeedsStatusBarAppearanceUpdate.assertValueCount(1)
  }

  func testSetInitialPagerViewController() {
    self.vm.inputs.configureWith(project: .template, refTag: .category)

    self.setInitialPagerViewController.assertValueCount(0)

    self.vm.inputs.viewDidLoad()

    self.setInitialPagerViewController.assertValueCount(1)
  }

  func testNotifyDelegateAfterSwipe() {
    let playlist = (0...4).map { idx in .template |> Project.lens.id .~ (idx + 42) }
    let project = playlist.first!

    self.vm.inputs.configureWith(project: project, refTag: .category)
    self.vm.inputs.viewDidLoad()

    self.vm.inputs.willTransition(toProject: playlist[1], at: 1)
    self.vm.inputs.pageTransition(completed: false, from: 0)

    self.notifyDelegateTransitionedToProjectIndex.assertValueCount(
      0, "Does not emit without completion of swipe."
    )
    XCTAssertEqual([], self.dataLakeTrackingClient.events)
    XCTAssertEqual([], self.segmentTrackingClient.events)

    self.vm.inputs.willTransition(toProject: playlist[1], at: 1)
    self.vm.inputs.pageTransition(completed: true, from: 0)

    self.notifyDelegateTransitionedToProjectIndex.assertValues([1])
    XCTAssertEqual(["Project Swiped"], self.dataLakeTrackingClient.events)
    XCTAssertEqual(["Project Swiped"], self.segmentTrackingClient.events)

    self.vm.inputs.willTransition(toProject: playlist[1], at: 2)
    self.vm.inputs.pageTransition(completed: true, from: 1)

    self.notifyDelegateTransitionedToProjectIndex.assertValues([1, 2])
    XCTAssertEqual(
      ["Project Swiped", "Project Swiped"],
      self.dataLakeTrackingClient.events
    )
    XCTAssertEqual(
      ["Project Swiped", "Project Swiped"],
      self.segmentTrackingClient.events
    )

    self.vm.inputs.willTransition(toProject: playlist[1], at: 1)
    self.vm.inputs.pageTransition(completed: true, from: 2)

    self.notifyDelegateTransitionedToProjectIndex.assertValues([1, 2, 1])
    XCTAssertEqual([
      "Project Swiped", "Project Swiped", "Project Swiped"
    ], self.dataLakeTrackingClient.events)
    XCTAssertEqual([
      "Project Swiped", "Project Swiped", "Project Swiped"
    ], self.segmentTrackingClient.events)
  }
}
