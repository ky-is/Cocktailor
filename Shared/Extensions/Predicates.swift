import Foundation

public protocol TypedPredicateProtocol: NSPredicate { associatedtype Root }
public final class CompoundPredicate<Root>: NSCompoundPredicate, TypedPredicateProtocol {}
public final class ComparisonPredicate<Root>: NSComparisonPredicate, TypedPredicateProtocol {}

extension ComparisonPredicate {
	convenience init<Value>(_ keyPath: KeyPath<Root, Value>, _ operation: NSComparisonPredicate.Operator, _ value: Any?) {
		let ex1 = \Root.self == keyPath ? NSExpression.expressionForEvaluatedObject() : NSExpression(forKeyPath: keyPath)
		let ex2 = NSExpression(forConstantValue: value)
		self.init(leftExpression: ex1, rightExpression: ex2, modifier: .direct, type: operation)
	}
}

//MARK: compound operators

public func && <LHS: TypedPredicateProtocol, RHS: TypedPredicateProtocol>(lhs: LHS, rhs: RHS) -> CompoundPredicate<LHS.Root> where LHS.Root == RHS.Root {
	CompoundPredicate(type: .and, subpredicates: [lhs, rhs])
}

public func || <LHS: TypedPredicateProtocol, RHS: TypedPredicateProtocol>(lhs: LHS, rhs: RHS) -> CompoundPredicate<LHS.Root> where LHS.Root == RHS.Root {
	CompoundPredicate(type: .or, subpredicates: [lhs, rhs])
}

public prefix func ! <TP: TypedPredicateProtocol>(p: TP) -> CompoundPredicate<TP.Root> {
	CompoundPredicate(type: .not, subpredicates: [p])
}

//MARK: comparison operators

public func == <E: Equatable, R, K: KeyPath<R, E>>(keyPath: K, value: E) -> ComparisonPredicate<R> {
	ComparisonPredicate(keyPath, .equalTo, value)
}

public func != <E: Equatable, R, K: KeyPath<R, E>>(keyPath: K, value: E) -> ComparisonPredicate<R> {
	ComparisonPredicate(keyPath, .notEqualTo, value)
}

public func > <C: Comparable, R, K: KeyPath<R, C>>(keyPath: K, value: C) -> ComparisonPredicate<R> {
	ComparisonPredicate(keyPath, .greaterThan, value)
}

public func < <C: Comparable, R, K: KeyPath<R, C>>(keyPath: K, value: C) -> ComparisonPredicate<R> {
	ComparisonPredicate(keyPath, .lessThan, value)
}

public func <= <C: Comparable, R, K: KeyPath<R, C>>(keyPath: K, value: C) -> ComparisonPredicate<R> {
	ComparisonPredicate(keyPath, .lessThanOrEqualTo, value)
}

public func >= <C: Comparable, R, K: KeyPath<R, C>>(keyPath: K, value: C) -> ComparisonPredicate<R> {
	ComparisonPredicate(keyPath, .greaterThanOrEqualTo, value)
}

public func === <S: Sequence, R, K: KeyPath<R, S.Element>>(keyPath: K, values: S) -> ComparisonPredicate<R> where S.Element: Equatable {
	ComparisonPredicate(keyPath, .in, values)
}
