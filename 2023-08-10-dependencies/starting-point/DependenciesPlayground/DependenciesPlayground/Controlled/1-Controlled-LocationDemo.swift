import MapKit
import SwiftUI

protocol LocationClient {
  var authorizationStatus: CLAuthorizationStatus { get }
  var delegateEvents: AsyncStream<DelegateEvent> { get }
  func requestWhenInUseAuthorization()
  func requestLocation()
}
enum DelegateEvent {
  case didChangeAuthorization(CLAuthorizationStatus)
  case didFail(Error)
  case didUpdateLocations([CLLocation])
}

class ControlledLocationDemoModel: NSObject, ObservableObject, CLLocationManagerDelegate {
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
    locationClient: any LocationClient = LiveLocationClient()
  ) {
    self.locationClient = locationClient
  }

  func locationButtonTapped() {
    if self.locationClient.authorizationStatus == .authorizedWhenInUse {
      self.locationClient.requestLocation()
    } else {
      self.locationClient.requestWhenInUseAuthorization()
    }
  }

  func task() async {
    for await event in self.locationClient.delegateEvents {
      switch event {
      case let .didChangeAuthorization(status):
        if status == .authorizedWhenInUse {
          self.locationClient.requestLocation()
        } else if status != .notDetermined {
        }

      case .didFail:
        break

      case let .didUpdateLocations(locations):
        guard let location = locations.last
        else { return }

        withAnimation {
          self.coordinateRegion.center = location.coordinate
          self.coordinateRegion.span.latitudeDelta = 0.01
          self.coordinateRegion.span.longitudeDelta = 0.01
        }
      }
    }
  }
}

struct ControlledLocationDemo: View {
  @ObservedObject var model: ControlledLocationDemoModel

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

struct ControlledLocationDemo_Previews: PreviewProvider {
  static var previews: some View {
    ControlledLocationDemo(
      model: ControlledLocationDemoModel(
        locationClient: MockLocationClient()
      )
    )
  }
}

class LiveLocationClient: NSObject, LocationClient, CLLocationManagerDelegate {
  let manager = CLLocationManager()
  let delegateEvents: AsyncStream<DelegateEvent>
  var delegateEventsContinuation: AsyncStream<DelegateEvent>.Continuation

  override init() {
    var continuation: AsyncStream<DelegateEvent>.Continuation!
    self.delegateEvents = AsyncStream {
      continuation = $0
    }
    self.delegateEventsContinuation = continuation
    super.init()
    self.manager.delegate = self
  }

  var authorizationStatus: CLAuthorizationStatus {
    self.manager.authorizationStatus
  }

  func requestWhenInUseAuthorization() {
    self.manager.requestWhenInUseAuthorization()
  }

  func requestLocation() {
    self.manager.requestLocation()
  }

  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    self.delegateEventsContinuation.yield(
      .didChangeAuthorization(manager.authorizationStatus)
    )
  }

  func locationManager(
    _ manager: CLLocationManager,
    didUpdateLocations locations: [CLLocation]
  ) {
    self.delegateEventsContinuation.yield(.didUpdateLocations(locations))
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    self.delegateEventsContinuation.yield(.didFail(error))
  }
}

struct MockLocationClient: LocationClient {
  let authorizationStatus: CLAuthorizationStatus
  let location: CLLocationCoordinate2D

  let delegateEvents: AsyncStream<DelegateEvent>
  let delegateContinuation: AsyncStream<DelegateEvent>.Continuation

  init(
    authorizationStatus: CLAuthorizationStatus = .authorizedWhenInUse,
    location: CLLocationCoordinate2D = CLLocationCoordinate2D(
      latitude: 34.0522300,
      longitude: -118.2436800
    )
  ) {
    self.authorizationStatus = authorizationStatus
    self.location = location
    var continuation: AsyncStream<DelegateEvent>.Continuation!
    self.delegateEvents = AsyncStream {
      continuation = $0
    }
    self.delegateContinuation = continuation
  }
  func requestWhenInUseAuthorization() {
    self.delegateContinuation.yield(.didChangeAuthorization(self.authorizationStatus))
  }
  func requestLocation() {
    self.delegateContinuation.yield(
      .didUpdateLocations([
        CLLocation(
          latitude: self.location.latitude,
          longitude: self.location.longitude
        )
      ])
    )
  }
}
