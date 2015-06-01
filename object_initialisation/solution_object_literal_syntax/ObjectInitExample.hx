using ObjectInit;

/**
ObjectInitExample

We want to create lots of `Person` objects. See if you can make a macro to save some keystrokes but achieves the same thing.

Can you create a macro to save a lot of lines of code here?

The same macro should be able to be used for both "Person" and "Job" objects.
**/
class ObjectInitExample {
	static function main() {
		var person1 = new Person().set({ name: "Jason", likes: [Burritos,Haxe], job: new Job().set({ role: "Developer", company: "Sheridan", pay: 50 }), });
		var person2 = new Person().set({ name: "Simon", likes: [Burritos,LongWalksOnBeach], job: new Job().set({ role: "Engineer", company: "Monadelphous", pay: 30 }), });
		var person3 = new Person().set({ name: "Chanelle", likes: [Netflix,LongWalksOnBeach], job: new Job().set({ role: "Designer", company: "Red Meets Blue", pay: 60 }), });
		var person4 = new Person().set({ name: "Justin", likes: [Haxe,Netflix,Burritos], job: new Job().set({ role: "IT", company: "Sheridan", pay: 60 }), });

		info( person1 );
		info( person2 );
		info( person3 );
		info( person4 );
	}

	static function info(p:Person) {
		trace('$p works as a ${p.job} for ${p.job.role}/hour. They like ${p.likes.join(", ")}.');
	}
}

class Person {
	public function new() {}
	public var name:String;
	public var likes:Array<Like>;
	public var job:Job;
	public static var people:Array<Person>;

	function toString() return name;
}

class Job {
	public function new() {}
	public var role:String;
	public var company:String;
	public var pay:Int;
	private var hat:String;
	function toString() return '$role at $company';
}

enum Like {
	Burritos;
	Haxe;
	LongWalksOnBeach;
	Netflix;
}
