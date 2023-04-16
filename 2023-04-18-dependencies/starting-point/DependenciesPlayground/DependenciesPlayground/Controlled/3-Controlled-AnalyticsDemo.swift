import MapKit
import SwiftUI

protocol Analytics {
  func track(_ event: String)
}

class ControlledAnalyticsDemoModel: NSObject, ObservableObject, CLLocationManagerDelegate {
  let analytics: any Analytics
  let locationClient: any LocationClient

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

  init(
    analytics: any Analytics = LiveAnalytics(),
    locationClient: any LocationClient = LiveLocationClient()
  ) {
    self.analytics = analytics
    self.locationClient = locationClient
  }

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
        break

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

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    self.analytics.track("Location request failed")
  }
}

struct ControlledAnalyticsDemo: View {
  @ObservedObject var model: ControlledAnalyticsDemoModel

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
    .task {
      await self.model.task()
    }
  }
}

struct ControlledAnalyticsDemo_Previews: PreviewProvider {
  static var previews: some View {
    ControlledAnalyticsDemo(
      model: ControlledAnalyticsDemoModel(
        analytics: NoopAnalytics(),
        locationClient: MockLocationClient(
          location: CLLocationCoordinate2D(
            latitude: 34.0522300,
            longitude: -118.2436800
          )
        )
      )
    )
  }
}

struct LiveAnalytics: Analytics {
  func track(_ event: String) {
    URLSession.shared
      .dataTask(with: URL(string: "/TODO")!) { _, _, _ in }
      .resume()
    print("Analytics tracked", event)
  }
}

struct NoopAnalytics: Analytics {
  func track(_ event: String) {
    print("[skipped]", "Analytics tracked", event)
  }
}
