import Foundation

func identity<T>(value: T?) -> T? {

    return value
}

// <http://owensd.io/2015/05/12/optionals-if-let.html>
func hasValue<T>(value: T?) -> Bool {
    switch (value) {
    case .Some(_): return true
    case .None: return false
    }
}

func bind<T, U>(optional: T?, _ f: T -> U?) -> U? {
    
    if let x = optional {
        return f(x)
    }
    else {
        return nil
    }
}

infix operator >>- { associativity left precedence 150 }

func >>-<T, U>(optional: T?, f: T -> U?) -> U? {
    
    return bind(optional, f)
}

infix operator |> { associativity left precedence 150 }

func |><T, U>(initial: T, f: T -> U) -> U {

    return f(initial)
}
