# Application Pipeline Stages

## Compile
In each section cover
 - Purpose
 - Key Performance Indicators
 - Tools

## Unit Testing
This stage in the pipeline verifies the functionality of individual code functions.  These test cases are the easiest to write and usually offer the most control for testing exception cases. The quality gates we are looking to validate here are:
* All unit tests are passing
* Code coverage of the unit tests is greater than the projects defined threshold. We recommend 90% as the goal.

Typically these unit test cases are written by the developers, often using the same programming language that the application is written in. This means that unit test execution is often done through the same tool that is used to compile the code. Tools such as:
* [Maven]() or [Gradle]() for Java projects
* [dotnet test]() for .Net projects
* [Apex tests](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_testing_unit_tests.htm#:~:text=Unit%20tests%20are%20class%20methods,annotation%20in%20the%20method%20definition.) for Salesforce projects

Key Performance Indicators (KPI) include:
* Percentage of code executed by the unit tests (Code Coverage)
* Number of unit tests

## Static Code Analysis
Static code analysis tools review the source code directly to look for insecure and problematic codeing patterns. The goal of this stage is to try and catch potential security issues, assess the maintainability of the codebase, and help enforce good coding standards. Tools that can be used for this analysis include:
* [SonarQube]() for application source code
* [Fortify](https://www.microfocus.com/en-us/cyberres/application-security/static-code-analyzer) for security scanning
* [tfsec](https://github.com/aquasecurity/tfsec) and [checkov](https://www.checkov.io/) for Terraform code
* [detect-secrets](https://github.com/Yelp/detect-secrets) monitors for sensitve data commited into the codebase



Key Performance Indicators (KPI) include:
* Number of issues found by severity
* Percentage of code duplication
* Cyclomatic complexity

## Package
During this stage you want to package your application for deployment/installation. The package should versioned be placed into an Artifact Repository where consumers can download it from. Examples of package repositories include:
* Nexus
* Artifactory
* GitHub Packages
* AWS CodeArtifact
* Azure Artifacts


## Deployment

## Testing

### Integration Testing

### Performance Testing

### Security Testing


# Examples
