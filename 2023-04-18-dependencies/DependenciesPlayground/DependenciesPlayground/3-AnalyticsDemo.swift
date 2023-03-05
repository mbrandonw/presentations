import MapKit
import SwiftUI

import PlaygroundPackage

class AnalyticsDemoModel: NSObject, ObservableObject, CLLocationManagerDelegate {
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

  override init() {
    super.init()
    self.manager.delegate = self
  }

  func locationButtonTapped() {
    AnalyticsClient.shared.track("Location button tapped")
    if self.manager.authorizationStatus == .notDetermined {
      AnalyticsClient.shared.track("Request authorization")
      self.manager.requestWhenInUseAuthorization()
    } else {
      self.manager.requestLocation()
    }
  }

  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    if self.manager.authorizationStatus == .authorizedWhenInUse {
      AnalyticsClient.shared.track("Authorization granted")
      self.manager.requestLocation()
    } else if self.manager.authorizationStatus != .notDetermined {
      AnalyticsClient.shared.track("Authorization denied")
    }
  }

  func locationManager(
    _ manager: CLLocationManager,
    didUpdateLocations locations: [CLLocation]
  ) {
    guard let location = locations.last
    else { return }

    AnalyticsClient.shared.track("Location request succeeded")

    withAnimation {
      self.coordinateRegion.center = location.coordinate
      self.coordinateRegion.span.latitudeDelta = 0.01
      self.coordinateRegion.span.longitudeDelta = 0.01
    }
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    AnalyticsClient.shared.track("Location request failed")
  }

  func onAppear() {
    AnalyticsClient.shared.track("Location demo appeared")
  }
}

struct AnalyticsDemo: View {
  @ObservedObject var model: AnalyticsDemoModel

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

struct AnalyticsDemo_Previews: PreviewProvider {
  static var previews: some View {
    AnalyticsDemo(model: AnalyticsDemoModel())
  }
}

struct AnalyticsClient {
  static let shared = AnalyticsClient()

  func track(_ event: String) {
    print("Analytics tracked", event)
  }
}
