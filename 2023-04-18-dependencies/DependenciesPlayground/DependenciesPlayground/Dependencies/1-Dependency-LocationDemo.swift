import Dependencies
import MapKit
import PlaygroundPackage
import SwiftUI

class DependencyLocationDemoModel: NSObject, ObservableObject, CLLocationManagerDelegate {
  @Dependency(\.analytics) var analytics
  @Dependency(\.locationClient) var locationClient

  @Published var coordinateRegion = MKCoordinateRegion(
    center: CLLocationCoordinate2D(
      latitude: 40.7545006,
      longitude: -73.9921813
    ),
    span: MKCoordinateSpan(
      latitudeDelta: 0.1,
      longitudeDelta: 0.1
    )
  )

  func locationButtonTapped() {
    self.analytics.track("Location button tapped")
    if self.locationClient.authorizationStatus == .notDetermined {
      self.analytics.track("Request authorization")
      self.locationClient.requestWhenInUseAuthorization()
    } else {
      self.locationClient.requestLocation()
    }
  }

  func task() async {
    self.analytics.track("Location demo appeared")

    for await event in self.locationClient.delegateEvents {
      switch event {
      case let .didChangeAuthorization(status):
        if status == .authorizedWhenInUse {
          self.analytics.track("Authorization granted")
          self.locationClient.requestLocation()
        } else if status != .notDetermined {
          self.analytics.track("Authorization denied")
        }
      case .didFail:
        self.analytics.track("Location request failed")

      case let .didUpdateLocations(locations):
        guard let location = locations.last
        else { return }

        self.analytics.track("Location request succeeded")

        withAnimation {
          self.coordinateRegion.center = location.coordinate
          self.coordinateRegion.span.latitudeDelta = 0.01
          self.coordinateRegion.span.longitudeDelta = 0.01
        }
      }
    }
  }
}

struct DependencyLocationDemo: View {
  @ObservedObject var model: DependencyLocationDemoModel

  var body: some View {
    ZStack(alignment: .bottomTrailing) {
      Map(coordinateRegion: self.$model.coordinateRegion)
        .ignoresSafeArea()

      Button {
        self.model.locationButtonTapped()
      } label: {
        Image(systemName: "location.fill")
          .font(.largeTitle)
          .padding(.all)
          .background(Color.white)
          .cornerRadius(1000)
          .shadow(radius: 10)
      }
      .buttonStyle(.plain)
      .padding(.all)
    }
    .task { await self.model.task() }
  }
}

struct DependencyLocationDemo_Previews: PreviewProvider {
  static var previews: some View {
    DependencyLocationDemo(
      model: DependencyLocationDemoModel()
    )
  }
}

private enum LocationClientKey: DependencyKey {
  static let liveValue: any LocationClient = LiveLocationClient()
  static let previewValue: any LocationClient = MockLocationClient(
    location: CLLocationCoordinate2D(
      latitude: 34.052235,
      longitude: -118.243683
    )
  )
}
private enum AnalyticsKey: DependencyKey {
  static let liveValue: any Analytics = LiveAnalytics()
  static let previewValue: any Analytics = NoopAnalytics()
}
extension DependencyValues {
  var locationClient: any LocationClient {
    get { self[LocationClientKey.self] }
    set { self[LocationClientKey.self] = newValue }
  }
  var analytics: any Analytics {
    get { self[AnalyticsKey.self] }
    set { self[AnalyticsKey.self] = newValue }
  }
}
