//
//  UIButton+PublisherUtility.swift
//  Private Streamer
//
//  Created by Derrek Larson on 4/26/24.
//
//Convenience utility for the easy creation of publishers for button interactions

import UIKit
import Combine

extension UIButton {
    func publisher(for controlEvents: UIControl.Event) -> UIControlPublisher {
        UIControlPublisher(control: self, events: controlEvents)
    }
}

struct UIControlPublisher: Publisher {
    typealias Output = Void
    typealias Failure = Never

    private let control: UIControl
    private let events: UIControl.Event

    init(control: UIControl, events: UIControl.Event) {
        self.control = control
        self.events = events
    }

    func receive<S: Subscriber>(subscriber: S) where Failure == S.Failure, Output == S.Input {
        let subscription = UIControlSubscription(
            subscriber: subscriber,
            control: control,
            events: events
        )
        subscriber.receive(subscription: subscription)
    }
}

final class UIControlSubscription<S: Subscriber>: Subscription where S.Input == Void {

    private var subscriber: S?

    init(subscriber: S, control: UIControl, events: UIControl.Event) {
        self.subscriber = subscriber
        control.addTarget(self, action: #selector(eventHandler), for: events)
    }

    func request(_ demand: Subscribers.Demand) {
        // Nothing to do here
    }

    func cancel() {
        subscriber = nil
    }

    @objc private func eventHandler() {
        _ = subscriber?.receive(())
    }
}
