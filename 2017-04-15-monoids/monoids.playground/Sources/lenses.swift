precedencegroup LeftApplyPrecendence {
  associativity: left
  higherThan: AssignmentPrecedence
  lowerThan: TernaryPrecedence
}

precedencegroup FunctionCompositionPrecedence {
  associativity: right
  higherThan: LeftApplyPrecendence
}

public struct Lens <Whole, Part> {
  public let view: (Whole) -> Part
  public let set: (Part, Whole) -> Whole
}

public struct Project {
  public let creator: User
  public let name: String
  public let state: State

  public enum State: Comparable {
    case live
    case successful

    public static func < (lhs: State, rhs: State) -> Bool {
      switch (lhs, rhs) {
      case (.live, .successful):
        return true
      case (.live, .live), (.successful, .live), (.successful, .successful):
        return false
      }
    }
  }
}

public struct User {
  public let location: Location
  public let name: String
}

public struct Location {
  public let name: String
}

extension Project {
  public enum lens {
    public static let creator = Lens<Project, User>(
      view: { $0.creator },
      set: { Project(creator: $0, name: $1.name, state: $1.state) }
    )
    public static let name = Lens<Project, String>(
      view: { $0.name },
      set: { Project(creator: $1.creator, name: $0, state: $1.state) }
    )
    public static let state = Lens<Project, Project.State>(
      view: { $0.state },
      set: { Project(creator: $1.creator, name: $1.name, state: $0) }
    )
  }
}

extension User {
  public enum lens {
    public static let name = Lens<User, String>(
      view: { $0.name },
      set: { User(location: $1.location, name: $0) }
    )
    public static let location = Lens<User, Location>(
      view: { $0.location },
      set: { User(location: $0, name: $1.name) }
    )
  }
}

extension Location {
  public enum lens {
    public static let name = Lens<Location, String>(
      view: { $0.name },
      set: { Location(name: $0.0) }
    )
  }
}

public let coolProject = Project(
    creator: .init(location: .init(name: "Los Angeles"), name: "Elan Lee"),
    name: "Exploding Kittens",
    state: .successful
)

public let projects: [Project] = [

  .init(
    creator: .init(location: .init(name: "San Francisco"), name: "Ozma Records"),
    name: "Voyager Golden Record: 40th Anniversary Edition",
    state: .live
  ),

  .init(
    creator: .init(location: .init(name: "Brooklyn"), name: "David Alvarado and Jason Sussberg"),
    name: "The Bill Nye Film",
    state: .live
  ),

  .init(
    creator: .init(location: .init(name: "Brooklyn"), name: "Lomography"),
    name: "The Lomography Lomo'Instant Camera",
    state: .live
  ),

  .init(
    creator: .init(location: .init(name: "Los Angeles"), name: "Elan Lee"),
    name: "Exploding Kittens",
    state: .successful
  ),

  .init(
    creator: .init(location: .init(name: "San Francisco"), name: "PRX, Inc"),
    name: "99% Invisible: Season 4- Weekly!",
    state: .successful
  ),

  .init(
    creator: .init(location: .init(name: "Los Angeles"), name: "LeVar Burton & Reading Rainbow"),
    name: "Bring Reading Rainbow Back for Every Child, Everywhere!",
    state: .successful
  ),

  .init(
    creator: .init(location: .init(name: "Los Angeles"), name: "Cloud Imperium Games Corp"),
    name: "Star Citizen",
    state: .live
  ),

  .init(
    creator: .init(location: .init(name: "San Francisco"), name: "Double Fine Productions"),
    name: "Double Fine Adventures",
    state: .successful
  ),

  .init(
    creator: .init(location: .init(name: "Minneapolis"), name: "Joel Hodgson"),
    name: "Bring Back MYSTERY SCIENCE THEATER 3000",
    state: .successful
  ),

  .init(
    creator: .init(location: .init(name: "Brooklyn"), name: "Cesar Kuriyama"),
    name: "1 Second Everyday App",
    state: .live
  ),
  
]

























infix operator .. : FunctionCompositionPrecedence

public func .. <A, B, C> (lhs: Lens<A, B>, rhs: Lens<B, C>) -> Lens<A, C> {
  return Lens(
    view: { rhs.view(lhs.view($0)) },
    set: { subPart, whole in
      let part = lhs.view(whole)
      let newPart = rhs.set(subPart, part)
      return lhs.set(newPart, whole)
  })
}


extension Lens where Whole == Project, Part == User {
  public var name: Lens<Project, String> {
    return Project.lens.creator..User.lens.name
  }
}

extension Lens where Whole == Project, Part == User {
  public var location: Lens<Project, Location> {
    return Project.lens.creator..User.lens.location
  }
}

extension Lens where Whole == Project, Part == Location {
  public var name: Lens<Project, String> {
    return Project.lens.creator.location..Location.lens.name
  }
}
