import ballerina/http;
import ballerina/io;

public function main() returns error? {
    http:Client clientEP = check new ("http://localhost:8080/programmes");

    // Add a new programme
    json newProgramme = {
        programmeCode: "CS101",
        nqfLevel: 7,
        qualificationTitle: "Bachelors of Computer Science",
        faculty: "Computer Science",
        department: "Software Engineering",
        registrationDate: "2020-01-10T00:00:00Z",
        courses: [
            { courseCode: "C101", courseName: "Introduction to Programming", nqfLevel: 5 },
            { courseCode: "C102", courseName: "Data Structures", nqfLevel: 6 },
            { courseCode: "C103", courseName: "Operating Systems", nqfLevel: 7 }
        ]
    };
    http:Response|anydata|stream<http:SseEvent, error?> _ = check clientEP->post("", newProgramme);

    // Retrieve all programmes
    json allProgrammes = check clientEP->get("");
    io:println("All Programmes: ", allProgrammes);

    // Retrieve details of a specific programme
    json specificProgramme = check clientEP->get("/CS101");
    io:println("Programme Details: ", specificProgramme);

    // Update a programme
    json updatedProgramme = {
        programmeCode: "CS101",
        nqfLevel: 8,
        qualificationTitle: "Bachelors of Computer Science (Honors)",
        faculty: "Computer Science",
        department: "Software Engineering",
        registrationDate: "2020-01-10T00:00:00Z",
        courses: [
            { courseCode: "C101", courseName: "Advanced Programming", nqfLevel: 8 },
            { courseCode: "C102", courseName: "Data Structures", nqfLevel: 6 },
            { courseCode: "C103", courseName: "Operating Systems", nqfLevel: 7 }
        ]
    };
    http:Response|anydata|stream<http:SseEvent, error?> _ = check clientEP->put("/CS101", updatedProgramme);

    // Delete a programme
    http:Response|anydata|stream<http:SseEvent, error?> _ = check clientEP->delete("/CS101");
}
