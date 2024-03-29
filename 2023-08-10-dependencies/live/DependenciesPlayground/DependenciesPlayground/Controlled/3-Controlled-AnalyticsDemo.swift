import MapKit
import SwiftUI

protocol Analytics {
  func track(_ event: String)
}

class ControlledAnalyticsDemoModel: NSObject, ObservableObject, CLLocationManagerDelegate {
  let analytics: any Analytics
  let manager = CLLocationManager()
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

  init(analytics: any Analytics = LiveAnalytics()) {
    self.analytics = analytics
    super.init()
    self.manager.delegate = self
  }

  func locationButtonTapped() {
    self.analytics.track("Location button tapped")
    if self.manager.authorizationStatus == .authorizedWhenInUse {
      self.manager.requestLocation()
    } else {
      self.analytics.track("Request authorization")
      self.manager.requestWhenInUseAuthorization()
    }
  }

  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    if self.manager.authorizationStatus == .authorizedWhenInUse {
      self.analytics.track("Authorization granted")
      self.manager.requestLocation()
    } else if self.manager.authorizationStatus != .notDetermined {
      self.analytics.track("Authorization denied")
    }
  }

  func locationManager(
    _ manager: CLLocationManager,
    didUpdateLocations locations: [CLLocation]
  ) {
    guard let location = locations.last
    else { return }

    self.analytics.track("Location request succeeded")

    withAnimation {
      self.coordinateRegion.center = location.coordinate
      self.coordinateRegion.span.latitudeDelta = 0.01
      self.coordinateRegion.span.longitudeDelta = 0.01
    }
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    self.analytics.track("Location request failed")
  }

  func onAppear() {
    self.analytics.track("Location demo appeared")
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
    .onAppear {
      self.model.onAppear()
    }
  }
}

struct ControlledAnalyticsDemo_Previews: PreviewProvider {
  static var previews: some View {
    ControlledAnalyticsDemo(
      model: ControlledAnalyticsDemoModel(
        analytics: NoopAnalytics()
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
