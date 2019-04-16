//
//  Every.swift
//  Meniny Lab
//
//  Blog  : https://meniny.cn
//  Github: https://github.com/Meniny
//
//  No more shall we pray for peace
//  Never ever ask them why
//  No more shall we stop their visions
//  Of selfdestructing genocide
//  Dogs on leads march to war
//  Go ahead end it all...
//
//  Blow up the world
//  The final silence
//  Blow up the world
//  I don't give a damn!
//
//  Screams of terror, panic spreads
//  Bombs are raining from the sky
//  Bodies burning, all is dead
//  There's no place left to hide
//  Dogs on leads march to war
//  Go ahead end it all...
//
//  Blow up the world
//  The final silence
//  Blow up the world
//  I don't give a damn!
//
//  (A voice was heard from the battle field)
//
//  "Couldn't care less for a last goodbye
//  For as I die, so do all my enemies
//  There's no tomorrow, and no more today
//  So let us all fade away..."
//
//  Upon this ball of dirt we lived
//  Darkened clouds now to dwell
//  Wasted years of man's creation
//  The final silence now can tell
//  Dogs on leads march to war
//  Go ahead end it all...
//
//  Blow up the world
//  The final silence
//  Blow up the world
//  I don't give a damn!
//
//  When I wrote this code, only I and God knew what it was.
//  Now, only God knows!
//
//  So if you're done trying 'optimize' this routine (and failed),
//  please increment the following counter
//  as a warning to the next guy:
//
//  total_hours_wasted_here = 0
//
//  Created by Elias Abel on 2018/1/5.
//  Copyright © 2018 MobiMagic. All rights reserved.
//

import Foundation

// MARK: - Every declaratiom
/// The `Every` class allows the user to easily create a scheduled action
open class Every {

    // MARK: - NextStep declaration
    /// The enumeration describes the next step `Every` has to do whenever the timer
    /// is triggered.
    ///
    /// - stop:       Stops the timer.
    /// - `continue`: Keeps the timer alive.
    public enum NextStep: Int {
        case stop = 0
        case `continue` = 1

        /// Stops the timer or not
        public var shouldStop: Bool {
            return self == .stop
        }
    }

    /// The perform closure. It has to return a `NextStep` type to let `Every` know
    /// what's the next operation to do.
    ///
    /// Return .continue to keep the timer alive, otherwise .stop to invalidate it.
    public typealias PerformClosure = () -> Every.NextStep

    public enum SecondsMultiplier {
        case toMilliseconds
        case toSeconds
        case toMinutes
        case toHours

        var value: Double {
            switch self {
            case .toMilliseconds:   return 1/1000
            case .toSeconds:        return 1
            case .toMinutes:        return 60
            case .toHours:          return 3600
            }
        }
    }

    // MARK: - Lifecycle
    /**
     Initialize a new `Every` object with an abstract value.
     Remember to use the variables `milliseconds`, `seconds`, `minutes` and
     `hours` to get the exact configuration

     - parameter value: The abstract value that describes the interval together
     with the time unit

     - returns: A new `Every` uncompleted instance
     */
    public init(_ value: TimeInterval) {
        self._value = value
    }

    private init() {
        fatalError("Please, speficy the time unit by using `milliseconds`, `seconds`, `minutes` abd `hours` properties.")
    }

    deinit {
        _timer?.invalidate()
    }

    // MARK: - Private properties
    /// The timer interval in seconds
    private let _value: TimeInterval

    /// The multiplier. If nil when using it, the configuration didn't go well,
    /// the app will crash
    fileprivate var _multiplier: Double? = nil

    /// The action to perform when the timer is triggered
    fileprivate var _performClosure: Every.PerformClosure?

    /// The timer instance
    private weak var _timer: Timer?

    /// Weak reference to the owner. Useful to check whether to stop or not the timer
    /// when the owner is deallocated
    fileprivate weak var _owner: AnyObject? {
        didSet {
            _checkOwner = _owner != nil
        }
    }

    /// It contains a boolean property that tells how to handle the tier trigger, checking or not for the
    /// owner instance.
    /// - Note: Do not change this value. The `_owner.didSet` will handle it
    fileprivate var _checkOwner = false

    // MARK: - Public properties
    /// Instance that runs the specific interval in milliseconds
    public lazy var milliseconds:  Every = self._make(value: self._value, .toMilliseconds)

    /// Instance that runs the specific interval in seconds
    public lazy var seconds:       Every = self._make(value: self._value, .toSeconds)

    /// /// Instance that runs the specific interval in minutes
    public lazy var minutes:       Every = self._make(value: self._value, .toMinutes)

    /// Instance that runs the specific interval in hours
    public lazy var hours:         Every = self._make(value: self._value, .toHours)

    fileprivate func _make(value time: TimeInterval, _ multiplierType: Every.SecondsMultiplier) -> Every {
        let each = Every(time)
        each._multiplier = multiplierType.value
        return each
    }

    /// Timer is stopped or not
    public private(set) var isStopped = true

    /// The definitive time interval to use for the timer. If nil, the app will crash
    public var timeInterval: TimeInterval? {
        guard let _multiplier = _multiplier else { return nil }
        return _multiplier * _value
    }

    // MARK: - Public methods
    /**
     Starts the timer and performs the action whenever the timer is triggered
     The closure should return a boolean that indicates to stop or not the timer after
     the trigger. Return `false` to continue, return `true` to stop it

     - parameter closure: The closure to execute whenever the timer is triggered.
     The closure should return a boolean that indicates to stop or not the timer after
     the trigger. Return `false` to continue, return `true` to stop it
     */
    @discardableResult
    public func perform(_ closure: @escaping Every.PerformClosure) -> Self {
        guard _timer == nil else { return self }
        guard let interval = timeInterval else { fatalError("Please, speficy the time unit by using `milliseconds`, `seconds`, `minutes` abd `hours` properties.") }

        isStopped = false
        _performClosure = closure
        _timer = Timer.scheduledTimer(
            timeInterval: interval,
            target: self,
            selector: .Triggered,
            userInfo: nil,
            repeats: true
        )
        return self
    }

    public func perform(on owner: AnyObject, closure: @escaping Every.PerformClosure) -> Self {
        _owner = owner
        return self.perform(closure)
    }

    @discardableResult
    public func `do`(_ closure: @escaping Every.PerformClosure) -> Self {
        return self.perform(closure)
    }
    /**
     Stops the timer
     */
    public func stop() {
        _timer?.invalidate()
        _timer = nil

        isStopped = true
    }

    /**
     Restarts the timer
     */
    @discardableResult
    public func restart() -> Self {
        guard let _performClosure = _performClosure else { fatalError("Don't call the method `start()` without stopping it before.") }

        return self.perform(_performClosure)
    }
}

// MARK: - Actions
fileprivate extension Every {
    @objc func _trigger(timer: Timer) {
        if _checkOwner && _owner == nil {
            stop()
            return
        }

        let stopTimer = _performClosure?().shouldStop ?? false

        guard stopTimer else { return }
        stop()
    }
}

// MARK: - Selectors
fileprivate extension Selector {
    static let Triggered = #selector(Every._trigger(timer:))
}

public extension Double {
    /// Instance that runs the specific interval in milliseconds
    var milliseconds: Every {
        return Every(self).milliseconds
    }

    /// Instance that runs the specific interval in seconds
    var seconds: Every {
        return Every(self).seconds
    }

    /// /// Instance that runs the specific interval in minutes
    var minutes: Every {
        return Every(self).minutes
    }

    /// Instance that runs the specific interval in hours
    var hours: Every {
        return Every(self).hours
    }
}

public extension Float {
    /// Instance that runs the specific interval in milliseconds
    var milliseconds: Every {
        return Every(TimeInterval(self)).milliseconds
    }

    /// Instance that runs the specific interval in seconds
    var seconds: Every {
        return Every(TimeInterval(self)).seconds
    }

    /// /// Instance that runs the specific interval in minutes
    var minutes: Every {
        return Every(TimeInterval(self)).minutes
    }

    /// Instance that runs the specific interval in hours
    var hours: Every {
        return Every(TimeInterval(self)).hours
    }
}

public extension Int {
    /// Instance that runs the specific interval in milliseconds
    var milliseconds: Every {
        return Every(TimeInterval(self)).milliseconds
    }

    /// Instance that runs the specific interval in seconds
    var seconds: Every {
        return Every(TimeInterval(self)).seconds
    }

    /// /// Instance that runs the specific interval in minutes
    var minutes: Every {
        return Every(TimeInterval(self)).minutes
    }

    /// Instance that runs the specific interval in hours
    var hours: Every {
        return Every(TimeInterval(self)).hours
    }
}

public typealias Do = Every

public extension Do {
    @discardableResult
    class func this(_ closure: @escaping Do.PerformClosure, every time: Every) -> Every {
        return time.perform(closure)
    }
}
