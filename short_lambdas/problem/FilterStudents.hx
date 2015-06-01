class FilterStudents {
	static var students = [
		{ first:"Abigail", surname:"Adams", gender:Female, grade:99 },
		{ first:"Alexander", surname:"Young", gender:Male, grade:12 },
		{ first:"Andrew", surname:"Moore", gender:Male, grade:41 },
		{ first:"Anthony", surname:"Lewis", gender:Male, grade:63 },
		{ first:"Christopher", surname:"Garcia", gender:Male, grade:99 },
		{ first:"Daniel", surname:"Harris", gender:Male, grade:93 },
		{ first:"David", surname:"Hill", gender:Male, grade:99 },
		{ first:"Elizabeth", surname:"Campbell", gender:Female, grade:26 },
		{ first:"Emily", surname:"Martinez", gender:Female, grade:53 },
		{ first:"Ethan", surname:"Taylor", gender:Male, grade:12 },
		{ first:"Grace", surname:"Stewart", gender:Female, grade:53 },
		{ first:"Hannah", surname:"Philips", gender:Female, grade:21 },
		{ first:"Isabella", surname:"Nelson", gender:Female, grade:45 },
		{ first:"Jacob", surname:"Willams", gender:Male, grade:55 },
		{ first:"Joseph", surname:"Robinson", gender:Male, grade:43 },
		{ first:"Joshua", surname:"Davis", gender:Male, grade:75 },
		{ first:"Madison", surname:"Baker", gender:Female, grade:76 },
		{ first:"Matthew", surname:"Miller", gender:Male, grade:84 },
		{ first:"Mia", surname:"Sanchez", gender:Female, grade:83 },
		{ first:"Michael", surname:"Jones", gender:Male, grade:21 },
		{ first:"Nicholas", surname:"King", gender:Male, grade:36 },
		{ first:"Olivia", surname:"Carter", gender:Female, grade:5 },
		{ first:"Ryan", surname:"Scott", gender:Male, grade:71 },
		{ first:"Sophia", surname:"Collins", gender:Female, grade:12 },
		{ first:"William", surname:"Clark", gender:Male, grade:100 },
	];

	static function main() {
		// See if you can create short Lambdas to make this code easier to read!

		var firstNamesStartingWithA = students.map(function(student) return student.first).filter(function(name) return StringTools.startsWith(name,"A"));
		var studentsWhoPassed = students.filter(function(student) return student.grade>=50);
		var girls = students.filter(function(student) return student.gender.match(Female));
		var boys = students.filter(function(student) return student.gender.match(Male));
		var studentIDs = Lambda.mapi(students, function(i,student) return '${student.first}_${student.surname}_${i}');

		var grades = [];
		doWithEach(students, function(student) {
			grades.push( student.grade );
		});
		var average = Lambda.fold(grades, function(total,grade) return total+grade, 0) / grades.length;
	}

	static function doWithEach<T>( iter:Iterable<T>, fn:T->Void ) {
		for ( item in iter )
			fn( item );
	}
}

enum Gender {
	Male;
	Female;
}
