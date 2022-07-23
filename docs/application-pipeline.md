# Application Pipeline Stages

## Compile
In each section cover
 - Purpose
 - Quality Gate
 - Tools

## Unit Testing
This stage in the pipeline verifies the functionality of individual code functions.  These test cases are the easiest to write and usually offer the most control for testing exception cases. The quality gates we are looking to validate here are:
* All unit tests are passing
* Code coverage of the unit tests is greater than the projects defined threshold. We recommend 90% as the goal.

Typically these unit test cases are written by the developers, often using the same programming language that the application is written in. This means that unit test execution is often done through the same tool that is used to compile the code. Tools such as:
* [Maven]() or [Gradle]() for Java projects
* [dotnet test]() for .Net projects
* [Apex tests](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_testing_unit_tests.htm#:~:text=Unit%20tests%20are%20class%20methods,annotation%20in%20the%20method%20definition.) for Salesforce projects

## Static Code Analysis
Static code analysis tools review the source code directly to look for insecure and problematic codeing patterns.

## Package

## Testing

### Functional Testing

### Performance Testing

### Security Testing

## Deployment



# Examples
