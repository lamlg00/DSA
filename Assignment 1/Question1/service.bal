import ballerina/http;
import ballerina/log;
import ballerina/time;

type Course record {
    string courseCode;
    string courseName;
    int nqfLevel;
};

type Programme record {
    string programmeCode;
    string qualificationTitle;
    int nqfLevel;
    string faculty;
    string department;
    time:Civil registrationDate;
    Course[] courses;
};

map<Programme> programmesMap = {};

// Function to create an error response
function createErrorResponse(string message) returns json {
    return {status: "error", message: message, data: {}};
}

// Function to create a success response
function createSuccessResponse(string message, json data) returns json {
    return {status: "success", message: message, data: data};
}

// Function to handle HTTP responses
function handleResponse(http:Caller caller, json response) returns error? {
    var result = caller->respond(response);
    if (result is error) {
        log:printError("Failed to send response", result);
    }
    return result;
}

// Validate Programme data
// Validate Programme data
function validateProgramme(Programme programme) returns error? {
    if programme.programmeCode == "" {
        return error("Programme code cannot be empty.");
    } else if (programme.nqfLevel < 1 || programme.nqfLevel > 10) {
        return error("NQF level must be between 1 and 10.");
    }
    return;
}


// Validate Course data
// Validate Course data
function validateCourse(Course course) returns error? {
    if course.courseCode == "" {
        return error("Course code cannot be empty.");
    } else if (course.nqfLevel < 1 || course.nqfLevel > 10) {
        return error("Course NQF level must be between 1 and 10.");
    }
    return;
}


service /programmes on new http:Listener(9090) {

    // Add a new programme
    resource function post programmes(http:Caller caller, http:Request req) returns error? {
        json|error potentialJSON = req.getJsonPayload();

        if potentialJSON is error {
            return handleResponse(caller, createErrorResponse("Bad JSON format"));
        }

        Programme|error maybeProgramme = potentialJSON.cloneWithType();
        if maybeProgramme is error {
            return handleResponse(caller, createErrorResponse("Invalid Programme JSON"));
        }

        // Validate programme data
        check validateProgramme(maybeProgramme);
        foreach var course in maybeProgramme.courses {
            check validateCourse(course);
        }

        if programmesMap.hasKey(maybeProgramme.programmeCode) {
            return handleResponse(caller, createErrorResponse("Programme with this code already exists"));
        }

        programmesMap[maybeProgramme.programmeCode] = maybeProgramme;

        json successResponse = createSuccessResponse("Programme added successfully!", maybeProgramme.toJson());
        return handleResponse(caller, successResponse);
    }

    // Get all programmes from storage
    resource function get programmes(http:Caller caller) returns error? {
        json[] programmeList = [];
        foreach var programme in programmesMap {
            programmeList.push(programme.toJson());
        }

        if programmeList.length() > 0 {
            return handleResponse(caller, createSuccessResponse("Retrieved all programmes", programmeList));
        } else {
            return handleResponse(caller, createErrorResponse("No programmes found"));
        }
    }

    // Get a specific programme by programmeCode
    resource function get programmes/[string programmeCode](http:Caller caller) returns error? {
        if programmesMap.hasKey(programmeCode) {
            Programme theProgramme = programmesMap.get(programmeCode);
            return handleResponse(caller, createSuccessResponse("Programme found", theProgramme.toJson()));
        } else {
            return handleResponse(caller, createErrorResponse("Programme not found"));
        }
    }

    // Get the courses of a specific programme
    resource function get programmes/[string programmeCode]/courses(http:Caller caller) returns error? {
        if programmesMap.hasKey(programmeCode) {
            Programme theProgramme = programmesMap.get(programmeCode);
            json[] coursesJson = theProgramme.courses.map(c => c.toJson());
            return handleResponse(caller, createSuccessResponse("Courses found", coursesJson));
        } else {
            return handleResponse(caller, createErrorResponse("Programme not found"));
        }
    }

    // Update an existing programme by programmeCode
    resource function put programmes/[string programmeCode](http:Caller caller, http:Request req) returns error? {
        json|error maybeJSON = req.getJsonPayload();
        if maybeJSON is error {
            return handleResponse(caller, createErrorResponse("Bad JSON format"));
        }

        Programme|error updatedProgramme = maybeJSON.cloneWithType();
        if updatedProgramme is error {
            return handleResponse(caller, createErrorResponse("Invalid Programme JSON"));
        }

        check validateProgramme(updatedProgramme);
        foreach var course in updatedProgramme.courses {
            check validateCourse(course);
        }

        if programmesMap.hasKey(programmeCode) {
            programmesMap[programmeCode] = updatedProgramme;
            return handleResponse(caller, createSuccessResponse("Programme updated successfully", updatedProgramme.toJson()));
        } else {
            return handleResponse(caller, createErrorResponse("Programme not found for update"));
        }
    }

    // Delete a programme by programmeCode
    resource function delete programmes/[string programmeCode](http:Caller caller) returns error? {
        if programmesMap.hasKey(programmeCode) {
            _ = programmesMap.remove(programmeCode);
            return handleResponse(caller, createSuccessResponse("Programme removed successfully", programmeCode.toJson()));
        } else {
            return handleResponse(caller, createErrorResponse("Programme not found"));
        }
    }

    // Get all programmes due for review (older than 5 years)
    resource function get programmes/dueForReview(http:Caller caller) returns error? {
        Programme[] programmesDueForReview = [];
        time:Civil currentDate = time:utcToCivil(time:utcNow());

        foreach var programme in programmesMap {
            time:Civil registrationDate = programme.registrationDate;
            int yearDifference = currentDate.year - registrationDate.year;

            if yearDifference >= 5 {
                programmesDueForReview.push(programme);
            }
        }

        if programmesDueForReview.length() > 0 {
            json[] jsonArray = programmesDueForReview.map(p => p.toJson());
            return handleResponse(caller, createSuccessResponse("Programmes due for review", jsonArray));
        } else {
            return handleResponse(caller, createErrorResponse("No programmes due for review"));
        }
    }

    // Get programmes by faculty

  resource function get programmes/faculty/[string facultyName](http:Caller caller) returns error? {
        Programme[] facultyProgrammes = [];
        foreach var programme in programmesMap {
            if programme.faculty == facultyName {
                facultyProgrammes.push(programme);
            }
        }

        if facultyProgrammes.length() > 0 {
            json[] jsonArray = facultyProgrammes.map(p => p.toJson());
            return handleResponse(caller, createSuccessResponse("Programmes in faculty: " + facultyName, jsonArray));
        } else {
            return handleResponse(caller, createErrorResponse("No programmes found in faculty: " + facultyName));
        }
    }
}


public function main() returns error? {
    // Start the service on port 9090
}
