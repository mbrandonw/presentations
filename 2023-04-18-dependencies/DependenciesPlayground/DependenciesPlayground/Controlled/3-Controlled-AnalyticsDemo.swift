import MapKit
import SwiftUI

import PlaygroundPackage

class ControlledAnalyticsDemoModel: NSObject, ObservableObject, CLLocationManagerDelegate {
  let manager = CLLocationManager()
  let analytics: any Analytics
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
  }

  func locationButtonTapped() {
    self.analytics.track("Location button tapped")
    if self.manager.authorizationStatus == .notDetermined {
      self.analytics.track("Request authorization")
      self.manager.requestWhenInUseAuthorization()
    } else {
      self.manager.requestLocation()
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

protocol Analytics {
  func track(_ event: String)
}

struct LiveAnalytics: Analytics {
  func track(_ event: String) {
    // TODO: URLSession.shared.dataTask(…)
    print("Analytics tracked", event)
  }
}

struct NoopAnalytics: Analytics {
  func track(_ event: String) {
  }
}
