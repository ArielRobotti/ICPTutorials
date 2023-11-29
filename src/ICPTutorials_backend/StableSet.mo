import Iter "mo:base/Iter";
import Array "mo:base/Array";

module {
    public type Set<T> = {
        table : [var T];
        initialSize : Nat;
        _numElem : Nat;
    };
    public func Set<T>(elem : ?[T], size : ?Nat) : Set<T> {
        switch (elem) {
            case null { 
                let table: [var T] = [var];
                let _numElem = 0;
                let initialSize = switch size{
                    case null {1};
                    case (?0) {1};
                    case (?value){value};
                };
                return {table; initialSize; _numElem};
            };
            case (?array) { 
                let table: [var T] = Iter.toArrayMut(array.vals());
                let _numElem = array.size();
                let initialSize = _numElem * 2;
                return {table; initialSize; _numElem};
            };
        };
            
    };

    public func vals<T>(s : Set<T>) : Iter.Iter<T> {
        return Iter.fromArrayMut(s.table);
    };

    public func append<T>(e : T) {

    };

};
