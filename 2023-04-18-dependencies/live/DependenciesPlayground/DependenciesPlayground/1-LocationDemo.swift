import MapKit
import SwiftUI

class LocationDemoModel: NSObject, ObservableObject, CLLocationManagerDelegate {
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
    if self.manager.authorizationStatus == .authorizedWhenInUse {
      self.manager.requestLocation()
    } else {
      self.manager.requestWhenInUseAuthorization()
    }
  }

  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    if self.manager.authorizationStatus == .authorizedWhenInUse {
      self.manager.requestLocation()
    }
  }

  func locationManager(
    _ manager: CLLocationManager,
    didUpdateLocations locations: [CLLocation]
  ) {
    guard let location = locations.last
    else { return }

    withAnimation {
      self.coordinateRegion.center = location.coordinate
      self.coordinateRegion.span.latitudeDelta = 0.01
      self.coordinateRegion.span.longitudeDelta = 0.01
    }
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    // TODO: show error
  }
}

struct LocationDemo: View {
  @ObservedObject var model: LocationDemoModel

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
          .shadow(radius: 20)
      }
      .buttonStyle(.plain)
      .padding(.all)
    }
  }
}

struct LocationDemo_Previews: PreviewProvider {
  static var previews: some View {
    LocationDemo(model: LocationDemoModel())
  }
}
