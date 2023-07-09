/*
 ARC automatically manages memory, by dealocating an object after its lifetime ends.
 ARC detemines an object's life time by keeping track of ist reference count.
 ARC is mainly driven by the Swift compiler which inserts retains and release operations.
 At runtime, 'retain' increments the reference count and 'release' decrements it.
 When the refernce drop to 0 the, the object will be dealocated
 
 An object's guaranteed minimum lifetime begins at initialization and ends at last use.
 */


class Person {
    var name: String
    var destination: String?
    
    init(name: String){
        self.name = name
        print("Person object init")
    }
    
    deinit {
        print("Person object deinit")
    }
}



/// swift compiler inserts a retain operation when a reference begins and a release operation after the last use of the reference.
func testPerson() {
    let person1 = Person(name: "Lily") // ref count 1 at runtime
    /// retain   // ref count 2 at runtime
    let person2 = person1
    /// release   // ref count 1 at runtime ; After the last use of the traveler1 reference, the release operation executes, decrementing the reference count to one.
    person2.destination = "Valey"
    /// release // ref count 0 at runtime
    print("Done traveling")
}



testPerson()

// Unlike default reference,  weak and unowned references do not participate in reference counting -> are commonly used to break reference counting

class Traveler {
    var name: String
    var destination: String?
    var account: Account?
    
    init(name: String){
        self.name = name
        print("Traveler object init")
    }
    
    deinit {
        print("Traveler object deinit")
    }
    
}

class Account {
    var traveler : Traveler?
    var points: Int
    
    init(traveler: Traveler, points : Int) {
        self.points = points
        self.traveler = traveler
        print("Account init")
    }
    
    deinit {
        print("Account deinit")
    }
    
    func printSummary() {
        if let traveler = traveler {
            print("\(traveler.name) has \(points) points")
        }
    }
}
/*
The different behavior for weak and unowned references stems from their underlying semantics:

Weak references are optional and can be nil, which allows them to gracefully handle the deallocation of the referenced object. You can safely check for nil before accessing a weak reference to avoid unexpected crashes or errors.
Unowned references, on the other hand, assume that the referenced object will always be valid throughout their usage. They are non-optional and assume a strong reference will always be present. When an unowned reference becomes invalid due to the deallocation of the target object, it violates this assumption, triggering a runtime trap.

 */
func testTraveler() {
    let traveler = Traveler(name: "Lily") /// refCountTraveler = 1
    let account = Account(traveler: traveler, points: 1000) /// refCountTraveler += 1 ; refCountAccount = 1
    traveler.account = account /// refCountAccount +=1 ; refCountAccount = 2 , refCountTraveler = 2
    ///refCountTraveler -=1
    account.printSummary()
    /// refCountAccount -=1
    /// refCountAccount = 1; refCountTraveler =1
    ///
}

/*
 Just created a referece cycle in the above code
 
 Solution:
 
 1. declaring in Account object:  weak var traveller. At first this may solve the problem but let't break it down:
    after this line of code  traveler.account = account, traveler is no longer used. So the reference counter of traveller can drop to 0 if the compiler inserted a release immediately after the last use. So, when calling account.printSummary() the force unwrap of the weak traveler reference will trap, causing a crash.
    Optional binding actually worsens the problem. Without an obvious crash, it creates a silent bug that may go unnoticed when the observed object lifetime changes for unrelated reasons.
 */

testTraveler()
 /*
  There are different techniques to safely handle weak and unowned references, each of them with varying degrees of upfront implementation cost versus continuous maintenance cost.
  
  1. Swift provides withExtendedLifetime() utility that can explicitly extend the lifetime of an object. However, this technique is fragile, and transfers the responsibility of correctness on you.With this approach, you should ensure withExtendedLifetime() is used every time a weak reference has a potential to cause bugs.If not controlled, withExtendedLifetime() can creep up all over the codebase, increasing maintenance cost.
  */


class Traveler1 {
    var name: String
    var destination: String?
    var account: Account?
    
    init(name: String){
        self.name = name
        print("Traveler1 object init")
    }
    
    deinit {
        print("Traveler1 object deinit")
    }
    
}

class Account1 {
    weak var traveler : Traveler?
    var points: Int
    
    init(traveler: Traveler, points : Int) {
        self.points = points
        self.traveler = traveler
        print("Account1 init")
    }
    
    deinit {
        print("Account1 deinit")
    }
    
    func printSummary() {
        if let traveler = traveler {
            print("\(traveler.name) has \(points) points")
        }
    }
}


func testTraveler1() {
    let traveler = Traveler(name: "Lily")
    let account = Account(traveler: traveler, points: 1000)
    /// for more complex cases
    //defer{withExtendedLifetime(traveler){}}
    traveler.account = account
    withExtendedLifetime(traveler) {
        account.printSummary()
    }
}

testTraveler1()


/*
 It is important to pause and think, why are weak and unowned references needed? Are they used only to break reference cycles? What if you avoid creating reference cycles in the first place? Reference cycles can often be avoided by rethinking algorithms and transforming cyclic class relationships to tree structures.
 */


class PersonalInfo {
    var name : String
    
    init(name: String) {
        self.name = name
    }
}

class Traveler2 {
    var info : PersonalInfo
    var account : Account?
    
    init(info: PersonalInfo, account: Account) {
        self.info = info
        self.account = account
    }
}

class Account2 {
    var info : PersonalInfo
    var points : Int
    
    init(info: PersonalInfo, points: Int) {
        self.info = info
        self.points = points
    }
    
}

/*
 Both Traveler class and Account class can refer to the PersonalInfo class, avoiding the cycle.

 Avoiding the need for weak and unowned references may have additional implementation cost, but this is a definite way to eliminate all potential object lifetime bugs.
 
 Cheers 🍺
 */






